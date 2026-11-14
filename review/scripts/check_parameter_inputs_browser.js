// Run through playwright-cli run-code --filename against the local preview.
async page => {
  page.setDefaultTimeout(30000);
  const checks = [];
  function check(name, passed) {
    checks.push({name, passed: Boolean(passed)});
    if (!passed) throw new Error(name);
  }
  async function settle() {
    await page.waitForFunction(() => !document.documentElement.classList.contains('shiny-busy'));
    await page.waitForTimeout(350);
  }
  async function choose(label, option) {
    await page.getByRole('combobox', {name: label, exact: true}).click();
    await page.locator('.selectize-dropdown:visible').getByText(option, {exact: true}).click();
    await settle();
  }
  const field = key => page.locator('[data-parameter-slider="prob1-' + key + '"]');
  const slider = key => page.locator('#prob1-' + key);
  async function enter(key, value) {
    await field(key).fill(String(value));
    await field(key).press('Enter');
    await settle();
  }
  async function state(key) {
    return slider(key).evaluate(node => {
      const control = jQuery(node).data('ionRangeSlider');
      const number = node.closest('.learning-parameter').querySelector('.learning-parameter-number');
      return {value: control.result.from, min: control.options.min,
        max: control.options.max, step: control.options.step, grid: control.options.grid,
        defaultStep: Number(number.dataset.parameterStep), integer: number.dataset.parameterInteger === 'true'};
    });
  }
  async function checkParameter(key, value) {
    const before = await state(key);
    await enter(key, value);
    check(key + '_number_updates_slider', (await state(key)).value === value);
    check(key + '_number_matches_slider', Number(await field(key).inputValue()) === value);
    check(key + '_no_invalid_state', await field(key).getAttribute('aria-invalid') === 'false');
    check(key + '_native_validation_accepts_precision', await field(key).evaluate(node => node.checkValidity()));
    check(key + '_default_step', before.defaultStep === (before.integer || key.startsWith('df') ? 1 : .1));
    for (const [label, invalid] of [['below_min', before.min - 1], ['above_max', before.max + 1], ['blank', '']]) {
      await enter(key, invalid);
      check(key + '_' + label + '_rejected', (await state(key)).value === value &&
        await field(key).getAttribute('aria-invalid') === 'true');
    }
    if (before.integer) {
      await enter(key, value + .5);
      check(key + '_fraction_rejected', (await state(key)).value === value &&
        await field(key).getAttribute('aria-invalid') === 'true');
    }
    // Drive the existing slider API and its normal change event.
    const dragged = before.integer ? value + 1 : value + .01;
    await slider(key).evaluate((node, next) => {
      jQuery(node).data('ionRangeSlider').update({from: next});
      jQuery(node).trigger('change');
    }, dragged);
    await settle();
    check(key + '_slider_updates_number', Number(await field(key).inputValue()) === (await state(key)).value);
    check(key + '_slider_clears_error', await field(key).getAttribute('aria-invalid') === 'false');
    check(key + '_ticks_retained', (await state(key)).grid);
    check(key + '_ticks_have_accurate_positions', await slider(key).evaluate(node => {
      const control = jQuery(node).data('ionRangeSlider');
      return [...node.closest('.learning-parameter').querySelectorAll('.learning-parameter-ticks .irs-grid-text')]
        .every(label => Math.abs(control.options.min + parseFloat(label.style.left) / 100 *
          (control.options.max - control.options.min) - Number(label.textContent)) < 1e-4);
    }));
    await enter(key, value);
    await field(key).press('ArrowUp');
    const incremented = Math.min(before.max, Number(((Math.floor(value / before.defaultStep + 1e-10) + 1) * before.defaultStep).toFixed(10)));
    check(key + '_increment_uses_default_step', Number(await field(key).inputValue()) === incremented);
    await enter(key, value);
    const plotId = (await page.locator('#prob1-learning_path').inputValue()) === 'core'
      ? '#prob1-pmf_plot' : '#prob1-pdf_plot_cont';
    check(key + '_plot_has_finite_values', await page.locator(plotId).evaluate(node =>
      node.data[0].y.some(Number.isFinite) && node.data[0].y.every(v => v === null || Number.isFinite(v))));
  }
  await page.goto('http://127.0.0.1:7130/');
  await page.waitForFunction(() => window.Shiny?.shinyapp?.isConnected());
  await page.setViewportSize({width: 1600, height: 1000});
  await page.getByRole('link', {name: /^percent icon Probability Distribution/}).click();
  await page.getByRole('link', {name: 'lightbulb icon Overview', exact: true}).click();
  await settle();
  check('all_24_inputs_connected', await page.locator('.learning-parameter-number[data-connected="true"]').count() === 24);
  check('all_inputs_have_accessible_labels', await page.locator('.learning-parameter-number').evaluateAll(nodes =>
    nodes.every(node => document.getElementById(node.getAttribute('aria-labelledby'))?.textContent.trim())));
  const models = [
    ['core', 'Bernoulli', [['p_bern', .61]]],
    ['core', 'Binomial', [['n', 7], ['p', .6]]],
    ['core', 'Geometric', [['pg', .61]]],
    ['core', 'Negative Binomial', [['r_nb', 4], ['p_nb', .6]]],
    ['core', 'Hypergeometric', [['N_hy', 20], ['n_hy', 6], ['M_hy', 7]]],
    ['core', 'Discrete Uniform', [['N_du', 3]]],
    ['core', 'Poisson', [['lambda', .61]]],
    ['preview', 'Uniform', [['a_unif', -2], ['b_unif', 3]]],
    ['preview', 'Exponential', [['rate_exp', 1.5]]],
    ['preview', 'Normal', [['mean_norm', -1.5], ['sd_norm', 1.2]]],
    ['further', 'Gamma', [['shape_gam', 2], ['rate_gam', 1.5]]],
    ['further', 'Beta', [['alpha_beta', 2], ['beta_beta', 3]]],
    ['further', 'Chi-Squared', [['df_chi', 4.5]]],
    ['further', "Student's t", [['df_t', 4.5]]],
    ['further', 'F', [['df1_f', 4.5], ['df2_f', 6.5]]]
  ];
  const paths = {core: 'STATS125 Core', preview: 'Optional STATS210 preview', further: 'Further exploration (optional)'};
  for (const [path, model, parameters] of models) {
    if (await page.locator('#prob1-learning_path').inputValue() !== path) await choose('Learning path', paths[path]);
    await choose(path === 'core' ? 'Choose discrete distribution' : 'Choose continuous distribution', model);
    for (const [key, value] of parameters) await checkParameter(key, value);
  }
  await choose('Learning path', paths.preview);
  await choose('Choose continuous distribution', 'Uniform');
  await enter('a_unif', 0);
  await enter('b_unif', 0);
  check('uniform_equal_bounds_rejected', (await state('b_unif')).value === 3 &&
    await field('b_unif').getAttribute('aria-invalid') === 'true');
  await enter('b_unif', .01);
  check('uniform_valid_narrow_interval', (await state('b_unif')).value === .01);
  await choose('Learning path', paths.core);
  await choose('Choose discrete distribution', 'Hypergeometric');
  await enter('n_hy', 18);
  await enter('M_hy', 19);
  await enter('N_hy', 12);
  await page.waitForFunction(() => ['n_hy', 'M_hy'].every(key => {
    const input = document.getElementById('prob1-' + key);
    const number = document.querySelector('[data-parameter-slider="' + input.id + '"]');
    return jQuery(input).data('ionRangeSlider').options.max === 12 && number.max === '12';
  }));
  for (const key of ['n_hy', 'M_hy']) {
    check(key + '_population_change_syncs_range', (await state(key)).max === 12 && await field(key).getAttribute('max') === '12');
    check(key + '_population_change_syncs_value', Number(await field(key).inputValue()) === 12 && (await state(key)).value === 12);
    await enter(key, 13);
    check(key + '_rejects_above_population', await field(key).getAttribute('aria-invalid') === 'true' && (await state(key)).value === 12);
  }
  await choose('Choose discrete distribution', 'Bernoulli');
  for (const value of [0, 1]) {
    await enter('p_bern', value);
    check('bernoulli_boundary_' + value, (await state('p_bern')).value === value &&
      await field('p_bern').getAttribute('aria-invalid') === 'false');
  }
  await enter('p_bern', .6);
  const line = page.locator('.learning-parameter:has(#prob1-p_bern) .irs-line');
  await line.scrollIntoViewIfNeeded();
  await page.waitForTimeout(600);
  const rect = await line.boundingBox();
  await line.click({position: {x: rect.width * .8, y: rect.height / 2}});
  await page.waitForFunction(() => document.getElementById('prob1-p_bern').value !== '0.6');
  await settle();
  check('actual_slider_pointer_updates_number', Number(await field('p_bern').inputValue()) === (await state('p_bern')).value &&
    (await state('p_bern')).value !== .6);
  await enter('p_bern', .61);
  await enter('p_bern', .6123);
  check('typed_precision_retained', (await state('p_bern')).value === .6123);
  await page.waitForFunction(() => document.getElementById('prob1-pmf_plot').data[0].y[1] === .6123);
  await field('p_bern').press('ArrowUp');
  await field('p_bern').press('Enter');
  await settle();
  check('numeric_spinner_updates_slider_with_default_step', Math.abs((await state('p_bern')).value - .7) < 1e-12);
  await enter('p_bern', .61);
  await field('p_bern').fill('.6');
  await page.getByRole('heading', {name: 'Parameters', exact: true}).click();
  await settle();
  check('blur_commits_number', (await state('p_bern')).value === .6);
  await enter('p_bern', .61);
  await page.getByRole('link', {name: 'Explore plots & parameters', exact: true}).click();
  await settle();
  await page.screenshot({path: 'output/playwright/parameter_inputs_wide.png'});
  await page.setViewportSize({width: 390, height: 844});
  await settle();
  check('mobile_no_horizontal_overflow', await page.locator('body').evaluate(node => node.scrollWidth <= innerWidth + 1));
  check('mobile_label_and_input_do_not_overlap', await field('p_bern').evaluate(node => {
    const label = node.closest('.learning-parameter').querySelector('label');
    return label.getBoundingClientRect().right + .5 >= node.getBoundingClientRect().right &&
      parseFloat(getComputedStyle(label).paddingRight) >= node.offsetWidth;
  }));
  await field('p_bern').scrollIntoViewIfNeeded();
  await page.screenshot({path: 'output/playwright/parameter_inputs_mobile.png'});
  await page.setViewportSize({width: 1600, height: 1000});
  await page.getByRole('link', {name: 'Explore plots & parameters', exact: true}).click();
  await page.bringToFront();
  return {passed: checks.filter(c => c.passed).length, total: checks.length};
}
