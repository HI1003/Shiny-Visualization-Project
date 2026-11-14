// Generic examples only. Run with playwright-cli run-code --filename.
async page => {
  page.setDefaultTimeout(30000);
  const cases=[];
  const check=(name,passed)=>{cases.push({name,passed:!!passed});if(!passed)throw Error(name);};
  const settle=async()=>{await page.waitForFunction(()=>!document.documentElement.classList.contains('shiny-busy'));await page.waitForTimeout(500);};
  const choose=async(label,text)=>{await page.getByRole('combobox',{name:label,exact:true}).click();await page.locator('.selectize-dropdown:visible').getByText(text,{exact:true}).click();await settle();};
  const ready=async(id)=>page.waitForFunction(id=>!!document.getElementById(id)?._distributionMeta,id);
  const position=async(id,index,yOverride)=>{
    await page.locator('#'+id).scrollIntoViewIfNeeded();
    await settle();
    return page.locator('#'+id).evaluate((n,{index,yOverride})=>{
      const r=n.getBoundingClientRect(),l=n._fullLayout,t=n.data[0];
      return {x:r.left+l.xaxis._offset+l.xaxis.l2p(t.x[index]),
        y:r.top+l.yaxis._offset+l.yaxis.l2p(yOverride===undefined?t.y[index]:yOverride)};
    },{index,yOverride});
  };
  const hover=async(id,index,yOverride)=>{const p=await position(id,index,yOverride);await page.mouse.move(p.x,p.y);await page.waitForTimeout(150);};
  const hoverAt=async(id,x,y)=>{
    await page.locator('#'+id).scrollIntoViewIfNeeded();
    await settle();
    const point=await page.locator('#'+id).evaluate((n,{x,y})=>{
      const rect=n.getBoundingClientRect(),layout=n._fullLayout;
      return {x:rect.left+layout.xaxis._offset+layout.xaxis.l2p(x),y:rect.top+layout.yaxis._offset+layout.yaxis.l2p(y)};
    },{x,y});
    await page.mouse.move(point.x,point.y);await page.waitForTimeout(150);
  };
  const hoverText=id=>page.locator('#'+id+' .hoverlayer,#'+id+' .learning-distribution-readout').allTextContents().then(parts=>parts.join(''));
  const linked=async(a,b)=>page.evaluate(({a,b})=>{
    const first=document.getElementById(a),second=document.getElementById(b);
    return Number.isInteger(first._distributionIndex)&&first._distributionIndex===second._distributionIndex&&
      [...first.querySelectorAll('.hoverlayer,.learning-distribution-readout')].some(n=>n.textContent.length>0)&&
      [...second.querySelectorAll('.hoverlayer,.learning-distribution-readout')].some(n=>n.textContent.length>0);
  },{a,b});
  await page.setViewportSize({width:1600,height:1000});await page.goto('http://127.0.0.1:7130/');
  await page.waitForFunction(()=>window.Shiny?.shinyapp?.isConnected());await settle();
  await page.getByRole('link',{name:/^percent icon Probability Distribution/}).click();
  await page.getByRole('link',{name:'lightbulb icon Overview',exact:true}).click();await ready('prob1-pmf_plot');await ready('prob1-cdf_plot');
  check('duplicate_readouts_removed',await page.locator('#prob1-sel_text,#prob1-sel_text_cont').count()===0&&await page.getByRole('heading',{name:'Current Selection',exact:true}).count()===0);
  check('distribution_presets_and_notes_removed',await page.locator('#prob1-plot_example,#prob1-example_controls,#prob1-example_note').count()===0);
  await hover('prob1-pmf_plot',1,.2);
  check('pmf_links_cdf',await linked('prob1-pmf_plot','prob1-cdf_plot'));
  check('bernoulli_correct_tooltips',(await page.locator('#prob1-pmf_plot .hoverlayer').textContent()).includes('P(X = 1) = 0.4')&&(await page.locator('#prob1-cdf_plot .hoverlayer').textContent()).includes('P(X ≤ 1) = 1'));
  check('bar_highlight',await page.locator('#prob1-pmf_plot .barlayer .point path').nth(1).evaluate(n=>n.style.fill==='rgb(33, 113, 181)'));
  await page.screenshot({path:'output/playwright/distribution_hover_wide.png'});
  await page.mouse.move(10,10);await page.waitForTimeout(150);
  check('mouse_leave_clears_both',await page.locator('#prob1-pmf_plot,#prob1-cdf_plot').evaluateAll(nodes=>nodes.every(n=>n._distributionIndex===null&&!n.querySelector('.hoverlayer').textContent)));
  await hover('prob1-cdf_plot',0,0);
  check('cdf_links_pmf',await linked('prob1-cdf_plot','prob1-pmf_plot'));
  check('open_endpoint_does_not_show_lower_value',(await hoverText('prob1-cdf_plot')).includes('P(X ≤ 0) = 0.6'));
  check('cdf_retains_open_and_closed_endpoints',await page.locator('#prob1-cdf_plot').evaluate(n=>n.data[0].mode==='markers'&&n.data[2].marker.symbol==='circle-open'&&[n.data[1].hoverinfo].flat().filter(Boolean).every(v=>v==='skip')));
  for(const [name,x,probability,cumulative] of [['left',-.5,0,0],['middle',.5,0,.6],['right',1.5,0,1],['before_jump',-.05,0,0],['after_jump',.05,0,.6]]) {
    await hoverAt('prob1-cdf_plot',x,cumulative);
    check('bernoulli_'+name+'_cdf_interval',(await hoverText('prob1-cdf_plot')).includes(') = '+cumulative));
    check('bernoulli_'+name+'_pmf_interval',(await hoverText('prob1-pmf_plot')).includes(') = '+probability));
    check('bernoulli_'+name+'_same_x',await page.locator('#prob1-pmf_plot,#prob1-cdf_plot').evaluateAll(nodes=>nodes[0]._distributionCursorX!==null&&nodes[0]._distributionCursorX===nodes[1]._distributionCursorX));
  }
  await page.screenshot({path:'output/playwright/cdf_interval_reading.png'});
  await page.mouse.move(10,10);await page.waitForTimeout(150);
  check('interval_readouts_clear_on_leave',await hoverText('prob1-pmf_plot')===''&&await hoverText('prob1-cdf_plot')==='');
  for(const [key,label] of [['bern','Bernoulli'],['binom','Binomial'],['geom','Geometric'],['nbinom','Negative Binomial'],['hyper','Hypergeometric'],['dunifd','Discrete Uniform'],['pois','Poisson']]){
    await choose('Choose discrete distribution',label);
    await page.waitForFunction(label=>document.getElementById('prob1-dist_desc').textContent.toLowerCase().includes(label.toLowerCase()),label);
    await settle();await hover('prob1-pmf_plot',0);
    check(key+'_hover_links',await linked('prob1-pmf_plot','prob1-cdf_plot'));
    check(key+'_compact_values',!/[0-9]\.[0-9]{5,}/.test(await page.locator('#prob1-plots .hoverlayer').allTextContents()));
    const first=await page.locator('#prob1-cdf_plot').evaluate(n=>n.data[0].x[0]);
    await hoverAt('prob1-cdf_plot',first-.5,0);
    check(key+'_cdf_below_support',(await hoverText('prob1-cdf_plot')).includes(') = 0'));
    check(key+'_pmf_below_support',(await hoverText('prob1-pmf_plot')).includes(') = 0'));
  }
  for(const [scope,models] of [
    ['Optional STATS210 preview',['Uniform','Exponential','Normal']],
    ['Further exploration (optional)',['Gamma','Beta','Chi-Squared',"Student's t",'F']]]){
    await choose('Learning path',scope);
    for(const model of models){
      await choose('Choose continuous distribution',model);await ready('prob1-pdf_plot_cont');await ready('prob1-cdf_plot_cont');await settle();
      await hover('prob1-pdf_plot_cont',await page.locator('#prob1-pdf_plot_cont').evaluate(n=>Math.floor(n.data[0].x.length*.55)));
      check(model+'_density_links_cdf',await linked('prob1-pdf_plot_cont','prob1-cdf_plot_cont'));
      check(model+'_density_not_point_probability',(await hoverText('prob1-pdf_plot_cont')).includes('Density is not P(X = x).'));
      await hover('prob1-cdf_plot_cont',await page.locator('#prob1-cdf_plot_cont').evaluate(n=>Math.floor(n.data[0].x.length*.35)));
      check(model+'_cdf_links_density',await linked('prob1-cdf_plot_cont','prob1-pdf_plot_cont'));
    }
  }
  await choose('Learning path','STATS125 Core');await choose('Choose discrete distribution','Bernoulli');await ready('prob1-pmf_plot');await settle();
  await hover('prob1-pmf_plot',1,.2);
  await page.locator('#prob1-p_bern').evaluate(input=>{jQuery(input).data('ionRangeSlider').update({from:.3});jQuery(input).trigger('change');});
  await page.waitForFunction(()=>document.getElementById('prob1-pmf_plot').data[0].y[1]===.3);await settle();
  check('parameter_change_clears_stale_hover',await page.locator('#prob1-pmf_plot,#prob1-cdf_plot').evaluateAll(nodes=>nodes.every(n=>n._distributionIndex===null)));
  await hover('prob1-pmf_plot',1,.15);
  check('updated_parameter_in_both_tooltips',(await page.locator('#prob1-pmf_plot .hoverlayer').textContent()).includes('= 0.3')&&await linked('prob1-pmf_plot','prob1-cdf_plot'));
  for(const width of [1600,900,390]){
    await page.setViewportSize({width,height:950});await settle();
    check('layout_'+width,await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  }
  const cdp=await page.context().newCDPSession(page);
  await cdp.send('Emulation.setTouchEmulationEnabled',{enabled:true});
  const touchRange=await page.locator('#prob1-pmf_plot').evaluate(n=>n._fullLayout.xaxis.range);
  for(const index of [0,1]){
    const p=await position('prob1-pmf_plot',index,.15);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:p.x,y:p.y}]});
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await page.waitForTimeout(200);
    check('touch_preserves_x_range_'+index,await page.locator('#prob1-pmf_plot,#prob1-cdf_plot').evaluateAll(
      (nodes,range)=>nodes.every(n=>JSON.stringify(n._fullLayout.xaxis.range)===JSON.stringify(range)),touchRange));
    check('touch_tap_'+index,await page.locator('#prob1-pmf_plot').evaluate((n,index)=>n._distributionIndex===index&&n._distributionPinned,index)&&await linked('prob1-pmf_plot','prob1-cdf_plot'));
  }
  await page.screenshot({path:'output/playwright/distribution_hover_touch.png'});
  await cdp.send('Emulation.setTouchEmulationEnabled',{enabled:false});await cdp.detach();
  await page.setViewportSize({width:1600,height:1000});await settle();await hover('prob1-pmf_plot',1,.15);
  check('no_visible_errors',await page.locator('.shiny-output-error:visible').count()===0);
  await page.bringToFront();
  return {passed:cases.filter(c=>c.passed).length,total:cases.length,cases};
}
