async page => {
  page.setDefaultTimeout(30000);
  const cases=[],measurements=[];
  const check=(name,passed)=>cases.push({name,passed:!!passed});
  const settle=async()=>{
    await page.evaluate(()=>window.__numberStable={key:'',at:performance.now()});
    await page.waitForFunction(()=>{
      const r=document.querySelector('.content-wrapper').getBoundingClientRect();
      const key=[innerWidth,Math.round(r.width),Math.round(r.x),document.documentElement.scrollWidth].join(',');
      const s=window.__numberStable;
      if(s.key!==key){s.key=key;s.at=performance.now();return false;}
      return performance.now()-s.at>700&&!document.documentElement.classList.contains('shiny-busy');
    });
  };
  const nav=async(name)=>{
    const link=page.getByRole('link',{name,exact:true});
    if(name==='lightbulb icon Overview'&&!await link.isVisible()){
      const group=page.getByRole('link',{name:/^percent icon Probability Distribution/});
      if(!await group.isVisible())await page.getByRole('link',{name:'bars icon',exact:true}).click();
      await group.click();
    }
    if(!await link.isVisible())await page.getByRole('link',{name:'bars icon',exact:true}).click();
    await link.click();await settle();
  };
  const firstLabel=prefix=>page.locator('#'+prefix+'-joint_table_html td[data-number-text]').first().getAttribute('data-number-text');
  await page.goto('http://127.0.0.1:7130/');await page.setViewportSize({width:1266,height:900});
  await nav('chart-area icon Joint Distribution');
  check('display_selector_removed',await page.locator('#number_format').count()===0);
  await page.waitForFunction(()=>document.querySelector('#joint1-joint_table_html td[data-number-text]')?.dataset.numberText==='188/221');
  check('auto_keeps_simple_fractions',await firstLabel('joint1')==='188/221');
  await page.locator('#joint1-pmf_example').evaluate(n=>n.selectize.setValue('counts20'));
  await page.locator('#joint1-load_pmf_example').click();
  await page.waitForFunction(()=>document.querySelector('#joint1-joint_table_html td[data-number-text]')?.dataset.numberText==='0.3');
  check('auto_short_decimals_without_trailing_zeroes',await firstLabel('joint1')==='0.3');
  await nav('chart-bar icon Conditional Distribution');
  await page.waitForFunction(()=>document.querySelector('#cond1-joint_table_html td[data-number-text]')?.dataset.numberText==='0.3');
  check('conditional_uses_auto',await firstLabel('cond1')==='0.3');
  await page.waitForFunction(()=>document.querySelector('#cond1-cond_table_html td[data-number-text]')?.dataset.numberText==='0.6');
  check('conditional_probability_uses_short_decimal',true);
  await nav('chart-line icon Expectation');
  await page.waitForFunction(()=>document.querySelector('#exp1-expectation_results')?.innerText.includes('E[X]'));
  check('expectation_uses_auto',await firstLabel('exp1')==='0.3');
  await nav('chart-area icon Joint Distribution');
  const weights=['0.123456789','0.234567891','0.345678912','0.296296408'];
  const inputs=page.locator('#joint1-input_panel .pmf-edit-prob input');
  for(let i=0;i<weights.length;i++)await inputs.nth(i).fill(weights[i]);
  await page.locator('#joint1-generate').click();
  await page.waitForFunction(()=>document.querySelector('#joint1-joint_table_html td[data-number-text]')?.dataset.numberText==='0.1235');
  const read=()=>page.locator('#joint1-joint_table_html td[data-number-value]').evaluateAll(ns=>ns.map(n=>Number(n.dataset.numberValue)));
  const before=await read();
  check('complex_probability_is_compact',await firstLabel('joint1')==='0.1235');
  check('rounded_cell_has_approximation_mark',(await page.locator('#joint1-joint_table_html td[data-number-text]').first().innerHTML()).includes('approx'));
  check('editor_compact_value',await inputs.first().inputValue()==='0.1235');
  check('editor_explains_approximation',(await page.locator('#joint1-input_panel .pmf-edit-prob').first().innerText()).includes('approx.'));
  check('full_precision_hover_available',(await page.locator('#joint1-input_panel .pmf-edit-prob').first().getAttribute('title')).includes('0.123456789'));
  for(let i=0;i<3;i++){
    const oldId=await inputs.first().getAttribute('id');await page.locator('#joint1-generate').click();
    await page.waitForFunction(id=>document.querySelector('#joint1-input_panel .pmf-edit-prob input')?.id!==id,oldId);await settle();
  }
  const after=await read();
  check('repeated_generate_does_not_commit_rounded_values',before.length===after.length&&before.every((v,i)=>Math.abs(v-after[i])<2e-15));
  const tiny=['0.00005','0.19995','0.3','0.5'];
  for(let i=0;i<tiny.length;i++)await inputs.nth(i).fill(tiny[i]);
  await page.locator('#joint1-generate').click();
  await page.waitForFunction(()=>Number(document.querySelector('#joint1-joint_table_html td[data-number-value]')?.dataset.numberValue)<.00006);
  check('small_nonzero_probability_is_not_displayed_as_zero',Number(await firstLabel('joint1'))>0);
  await inputs.first().fill('0.12');await page.locator('#joint1-generate').click();await settle();
  await page.waitForFunction(()=>Math.abs(Number(document.querySelector('#joint1-joint_table_html td[data-number-value]')?.dataset.numberValue)-.123456789)>1e-4);
  check('intentional_edit_is_applied',true);
  for(const [module,prefix,link] of [['joint','joint1',null],['conditional','cond1','chart-bar icon Conditional Distribution'],['expectation','exp1','chart-line icon Expectation']]){
    await page.setViewportSize({width:1266,height:900});await settle();if(link)await nav(link);
    for(const width of [1600,1266,900,390]){
      await page.setViewportSize({width,height:900});await settle();
      const m=await page.locator('#'+prefix+'-workbench').evaluate(n=>({viewport:innerWidth,pageWidth:document.documentElement.scrollWidth,
        inputLengths:Array.from(n.querySelectorAll('.pmf-edit-prob input')).map(i=>i.value.length),
        clippedLabels:Array.from(n.querySelectorAll('label')).filter(e=>e.getClientRects().length&&e.scrollWidth>e.clientWidth+3).length}));
      measurements.push({module,...m});check(module+'_'+width+'_compact_readable_layout',m.pageWidth<=width+1&&m.clippedLabels===0&&m.inputLengths.every(n=>n<=12));
      if(width===1266||width===390){await page.locator('#'+prefix+'-explorer').scrollIntoViewIfNeeded();await page.screenshot({path:'output/playwright/numbers_'+module+'_'+width+'.png'});}
    }
  }
  await page.setViewportSize({width:1266,height:900});await settle();await nav('house icon Home');
  await nav('lightbulb icon Overview');await settle();
  await page.locator('#prob1-plot_example').evaluate(n=>n.selectize.setValue('eggs_cloudy'));
  await page.locator('#prob1-load_plot_example').click();
  await page.waitForFunction(()=>document.getElementById('prob1-sel_text')?.innerText.includes('0.3472'));await settle();
  check('overview_current_selection_uses_four_decimals',(await page.locator('#prob1-sel_text').innerText()).includes('0.3472'));
  await page.locator('#prob1-selection_precision > details > summary').click();
  check('overview_more_precision_is_available',(await page.locator('#prob1-selection_precision').innerText()).includes('0.347229'));
  await page.setViewportSize({width:390,height:900});await settle();
  check('overview_narrow_precision_panel_fits',await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await page.setViewportSize({width:1266,height:900});await settle();
  return {date:new Date().toISOString(),passed:cases.filter(c=>c.passed).length,total:cases.length,cases,measurements,
    screenshots:'Generic application examples only; screenshots remain in ignored output/playwright.'};
}
