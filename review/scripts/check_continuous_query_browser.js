// Run with playwright-cli run-code --filename. Uses generic distributions only.
async page => {
  page.setDefaultTimeout(30000);
  const checks = [];
  function check(name, passed) {
    checks.push({name, passed: Boolean(passed)});
    if (!passed) throw new Error(name);
  }
  async function choose(label, text) {
    await page.getByRole('combobox', {name: label, exact: true}).click();
    await page.locator('.selectize-dropdown:visible').getByText(text, {exact: true}).click();
  }
  async function enter(key, value) {
    const field = page.locator('[data-parameter-slider="prob1-' + key + '"]');
    await field.fill(String(value));
    await field.press('Enter');
  }
  async function position(id, x, y) {
    await page.locator('#' + id).scrollIntoViewIfNeeded();
    await page.waitForTimeout(400);
    return page.locator('#' + id).evaluate((node, point) => {
      const rect = node.getBoundingClientRect(), layout = node._fullLayout;
      return {x: rect.left + layout.xaxis._offset + layout.xaxis.l2p(point.x),
        y: rect.top + layout.yaxis._offset + layout.yaxis.l2p(point.y)};
    }, {x, y});
  }
  async function verify(name, step, rawX, selectedX, density, cumulative) {
    await page.waitForFunction(({step, selectedX, density, cumulative}) => {
      const pdf = document.getElementById('prob1-pdf_plot_cont');
      const cdf = document.getElementById('prob1-cdf_plot_cont');
      const index = pdf._distributionMeta?.reading?.x.indexOf(selectedX);
      return index >= 0 && pdf._distributionMeta?.reading?.step === step &&
        pdf._distributionMeta.reading.signature === cdf._distributionMeta?.reading?.signature &&
        Math.abs(pdf._distributionMeta.reading.density[index] - density) < 1e-10 &&
        Math.abs(cdf._distributionMeta.reading.cumulative[index] - cumulative) < 1e-12;
    }, {step, selectedX, density, cumulative});
    for (const [id, y] of [['prob1-pdf_plot_cont', density], ['prob1-cdf_plot_cont', cumulative]]) {
      const point = await position(id, rawX, y);
      await page.mouse.move(point.x, point.y);
      await page.waitForTimeout(120);
      const actual = await page.locator('#prob1-pdf_plot_cont,#prob1-cdf_plot_cont').evaluateAll(nodes => nodes.map(node => ({
        x: node._distributionCursorX, value: node._distributionMeta.probability ?
          node._distributionMeta.reading.cumulative[node._distributionIndex] : node._distributionMeta.reading.density[node._distributionIndex],
        text: [...node.querySelectorAll('.hoverlayer,.learning-distribution-readout')].map(n=>n.textContent).join(''), curvePoints: node.data[1].x.length
      })));
      check(name + '_' + id + '_same_x', actual.every(value => value.x === selectedX));
      check(name + '_' + id + '_density_recomputed', Math.abs(actual[0].value - density) < 1e-10);
      check(name + '_' + id + '_cdf_recomputed', Math.abs(actual[1].value - cumulative) < 1e-12);
      check(name + '_' + id + '_tooltip_x_matches_values', actual.every(value => value.text.includes('x = ' + selectedX)));
      check(name + '_' + id + '_smooth_curve_retained', actual.every(value => value.curvePoints >= 600));
    }
  }
  await page.goto('http://127.0.0.1:7130/');
  await page.setViewportSize({width: 1600, height: 1000});
  await page.waitForFunction(() => window.Shiny?.shinyapp?.isConnected());
  await page.getByRole('link', {name: /^percent icon Probability Distribution/}).click();
  await page.getByRole('link', {name: 'lightbulb icon Overview', exact: true}).click();
  await choose('Learning path', 'Optional STATS210 preview');
  await choose('Choose continuous distribution', 'Normal');
  await verify('normal', .1, -1.0751, -1.1, .21785217703255053, .13566606094638267);
  await verify('normal_zero', .1, .0049, 0, 1 / Math.sqrt(2 * Math.PI), .5);
  await enter('sd_norm', .01);
  await verify('narrow_normal', .001, -.010751, -.011, .21785217703255053 / .01, .13566606094638267);
  await choose('Choose continuous distribution', 'Uniform');
  await enter('a_unif', 0); await enter('b_unif', 1);
  await verify('uniform', .01, .314159, .31, 1, .31);
  await enter('b_unif', 100);
  await verify('wide_uniform', 1, 30.6, 31, .01, .31);
  await enter('b_unif', .0001);
  await verify('narrow_uniform', .000001, .0000314159, .000031, 10000, .31);
  await choose('Choose continuous distribution', 'Exponential');
  await verify('exponential', .1, 1.34, 1.3, Math.exp(-1.3), 1 - Math.exp(-1.3));
  await enter('rate_exp', 10);
  await verify('fast_exponential', .01, .134, .13, 10 * Math.exp(-1.3), 1 - Math.exp(-1.3));
  await choose('Learning path', 'Further exploration (optional)');
  await choose('Choose continuous distribution', 'Gamma');
  await enter('shape_gam', 2);
  await verify('gamma', .1, 1.34, 1.3, 1.3 * Math.exp(-1.3), 1 - Math.exp(-1.3) * 2.3);
  await choose('Choose continuous distribution', 'Beta');
  await enter('alpha_beta', 2); await enter('beta_beta', 2);
  await verify('beta', .01, .314159, .31, 6 * .31 * .69, 3 * .31 ** 2 - 2 * .31 ** 3);
  await choose('Choose continuous distribution', 'Chi-Squared');
  await enter('df_chi', 2);
  await verify('chi_squared', .2, 1.07, 1, .5 * Math.exp(-.5), 1 - Math.exp(-.5));
  await choose('Choose continuous distribution', "Student's t");
  await enter('df_t', 1);
  await verify('student_t', 10, 10.751, 10, 1 / (Math.PI * 101), .5 + Math.atan(10) / Math.PI);
  await choose('Choose continuous distribution', 'F');
  await enter('df1_f', 2); await enter('df2_f', 2);
  await verify('f_distribution', 10, 30.8, 30, 1 / 31 ** 2, 30 / 31);
  await choose('Choose continuous distribution', 'Gamma'); await enter('shape_gam', .5);
  await page.waitForFunction(() => {
    const pdf = document.getElementById('prob1-pdf_plot_cont');
    const cdf = document.getElementById('prob1-cdf_plot_cont');
    const index = cdf._distributionMeta?.reading?.x.indexOf(0);
    return index >= 0 && pdf._distributionMeta?.reading?.signature === cdf._distributionMeta?.reading?.signature &&
      pdf._distributionMeta.reading.density[index] === null;
  });
  const endpoint = await position('prob1-cdf_plot_cont', 0, 0);
  await page.mouse.move(endpoint.x, endpoint.y); await page.waitForTimeout(150);
  check('singular_endpoint_does_not_claim_zero_density', (await page.locator('#prob1-pdf_plot_cont .learning-distribution-readout').textContent()).includes('unbounded'));
  check('singular_endpoint_cdf_is_available', (await page.locator('#prob1-cdf_plot_cont .learning-distribution-readout').textContent()).includes('= 0'));
  await choose('Learning path', 'Optional STATS210 preview');
  await choose('Choose continuous distribution', 'Normal'); await enter('sd_norm', 1);
  await verify('restored_normal', .1, -1.0751, -1.1, .21785217703255053, .13566606094638267);
  await page.evaluate(async () => {await document.fonts.ready;});
  await page.screenshot({path: 'output/playwright/continuous_query_wide_20261114.png'});
  await page.setViewportSize({width: 390, height: 950});
  await page.waitForTimeout(600);
  check('mobile_no_horizontal_overflow', await page.locator('html').evaluate(node => node.scrollWidth <= innerWidth + 1));
  const cdp = await page.context().newCDPSession(page);
  await cdp.send('Emulation.setTouchEmulationEnabled', {enabled: true});
  for (const id of ['prob1-pdf_plot_cont', 'prob1-cdf_plot_cont']) {
    const point = await position(id, -1.0751, id.includes('pdf') ? .2238 : .1412);
    await cdp.send('Input.dispatchTouchEvent', {type: 'touchStart', touchPoints: [point]});
    await cdp.send('Input.dispatchTouchEvent', {type: 'touchEnd', touchPoints: []});
    await page.waitForTimeout(200);
    check(id + '_touch_uses_shared_snapped_x', await page.locator('#prob1-pdf_plot_cont,#prob1-cdf_plot_cont').evaluateAll(nodes =>
      nodes.every(node => node._distributionCursorX === -1.1 && node._distributionPinned)));
    check(id + '_touch_readouts_stay_inside_axes', await page.locator('#prob1-pdf_plot_cont,#prob1-cdf_plot_cont').evaluateAll(nodes =>
      nodes.every(node => {
        const plot=node.getBoundingClientRect(), text=node.querySelector('.learning-distribution-readout').getBoundingClientRect();
        const left=plot.left+node._fullLayout.xaxis._offset;
        return text.left>=left-1 && text.right<=left+node._fullLayout.xaxis._length+1;
      })));
  }
  await page.screenshot({path: 'output/playwright/continuous_query_mobile_20261114.png'});
  await cdp.send('Emulation.setTouchEmulationEnabled', {enabled: false}); await cdp.detach();
  await page.setViewportSize({width: 1600, height: 1000});
  await page.mouse.move(10, 10); await page.waitForTimeout(900);
  await verify('final_normal', .1, -1.0751, -1.1, .21785217703255053, .13566606094638267);
  await page.bringToFront();
  return {passed: checks.filter(c => c.passed).length, total: checks.length, checks};
}
