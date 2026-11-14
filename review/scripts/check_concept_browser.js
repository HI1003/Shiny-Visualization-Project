async page => {
  page.setDefaultTimeout(30000);
  const url=page.url(),cases=[],measurements=[];
  if(!/^http:\/\/(127\.0\.0\.1|localhost):[0-9]+\//.test(url))throw new Error('Open the local Shiny app first.');
  const check=(name,passed,detail='')=>cases.push({name,passed:!!passed,detail});
  const settle=async()=>{
    await page.evaluate(()=>window.__conceptStable={key:'',at:performance.now()});
    await page.waitForFunction(()=>{
      const r=document.querySelector('.content-wrapper').getBoundingClientRect();
      const key=[innerWidth,Math.round(r.width),Math.round(r.x),document.documentElement.scrollWidth].join(',');
      const state=window.__conceptStable;
      if(state.key!==key){state.key=key;state.at=performance.now();return false;}
      return performance.now()-state.at>700&&!document.documentElement.classList.contains('shiny-busy');
    });
  };
  const nav=async(name)=>{
    const link=page.getByRole('link',{name,exact:true});
    if(!await link.isVisible())await page.getByRole('link',{name:'bars icon',exact:true}).click();
    await link.click();
  };
  await page.goto(url);await page.setViewportSize({width:1266,height:900});
  await page.getByRole('button',{name:'play icon Review STATS125 concepts',exact:true}).waitFor();
  check('optional_progress_not_promoted',!await page.locator('.learning-optional-progress').evaluate(n=>n.open));
  await page.getByRole('button',{name:'play icon Review STATS125 concepts',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='prob1-theory');
  check('home_opens_concept_review',true);
  const modules=[['overview','prob1',null],['joint','joint1','chart-area icon Joint Distribution'],
    ['conditional','cond1','chart-bar icon Conditional Distribution'],['expectation','exp1','chart-line icon Expectation']];
  for(const [module,prefix,link] of modules){
    await page.setViewportSize({width:1266,height:900});await settle();if(link)await nav(link);
    await page.locator('#'+prefix+'-theory').waitFor();await settle();
    const state=await page.evaluate(prefix=>{
      const theory=document.getElementById(prefix+'-theory'),explorer=document.getElementById(prefix+'-explorer'),practice=document.getElementById(prefix+'-practice');
      return {reviewFirst:!!(theory.compareDocumentPosition(explorer)&Node.DOCUMENT_POSITION_FOLLOWING),
        practiceLast:!!(explorer.compareDocumentPosition(practice)&Node.DOCUMENT_POSITION_FOLLOWING),
        reviewVisible:theory.getClientRects().length>0,practiceCollapsed:practice.tagName==='DETAILS'&&!practice.open};
    },prefix);
    check(module+'_concepts_then_visuals_then_optional',state.reviewFirst&&state.practiceLast,state);
    check(module+'_concepts_visible_and_practice_closed',state.reviewVisible&&state.practiceCollapsed,state);
    await page.getByRole('link',{name:'Review key ideas',exact:true}).click();
    check(module+'_review_jump',await page.evaluate(id=>document.activeElement.id===id,prefix+'-theory'));
    for(const width of [1600,1266,900,390]){
      await page.setViewportSize({width,height:900});await settle();await page.evaluate(()=>scrollTo(0,0));
      const metrics=await page.locator('#'+prefix+'-theory').evaluate((theory,prefix)=>{
        const module=theory.closest('.learning-module');
        const clipped=Array.from(module.querySelectorAll('p,label')).filter(n=>n.getClientRects().length&&!n.querySelector('.MathJax,.MathJax_SVG')&&n.scrollWidth>n.clientWidth+3).map(n=>n.innerText.slice(0,70));
        const table=document.getElementById(prefix+'-workbench')?.querySelector('table'),t=table?.getBoundingClientRect();
        const bound=document.getElementById(prefix+'-workbench')?.getBoundingClientRect();
        return {viewport:innerWidth,documentWidth:document.documentElement.scrollWidth,reviewWidth:theory.clientWidth,clipped,
          tableFits:!table||(t.left>=bound.left-1&&t.right<=bound.right+1)};
      },prefix);
      measurements.push({module,...metrics});
      check(module+'_'+width+'_readable_no_page_overflow',metrics.documentWidth<=width+1&&!metrics.clipped.length,metrics);
      check(module+'_'+width+'_default_table_fits',metrics.tableFits);
      if(width===1266||width===390)await page.screenshot({path:'output/playwright/concept_'+module+'_'+width+'.png'});
    }
    await page.setViewportSize({width:1266,height:900});await settle();
    await page.getByRole('link',{name:module==='overview'?'Explore plots & parameters':'Explore tables & plots',exact:true}).click();
    check(module+'_visual_jump_without_quiz',await page.evaluate(id=>document.activeElement.id===id,prefix+'-explorer'));
    check(module+'_quiz_still_optional',!await page.locator('#'+prefix+'-practice').evaluate(n=>n.open));
    await page.getByRole('link',{name:'Optional practice',exact:true}).click();
    await page.locator('#'+prefix+'-practice .practice-progress').waitFor();
    const provenance=await page.locator('#'+prefix+'-question_meta').innerText();
    check(module+'_source_label_honest',provenance.includes(module==='expectation'?'past-exam source not verified':'Original self-check example; not a past-exam question'));
    await page.locator('#'+prefix+'-practice > summary').click();
    if(module==='joint')check('joint_3d_removed',await page.locator('#joint1-plots .learning-3d').count()===0);
    if(module==='conditional')check('conditional_3d_removed',await page.locator('#cond1-plots .learning-3d').count()===0);
  }
  await nav('house icon Home');
  await page.getByRole('button',{name:'Explore joint probability',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='joint1-theory');
  check('home_joint_opens_review_not_quiz',!await page.locator('#joint1-practice').evaluate(n=>n.open));
  await nav('house icon Home');await page.getByRole('button',{name:'play icon Review STATS125 concepts',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='prob1-theory');
  await page.locator('#prob1-plot_example').evaluate(n=>n.selectize.setValue('eggs_cloudy'));
  await page.getByRole('button',{name:'Load example',exact:true}).click();
  await page.getByText('F(10) = P(X ≤ 10) = 0.347229',{exact:false}).waitFor();
  check('poisson_visual_works_without_practice',!await page.locator('#prob1-practice').evaluate(n=>n.open));
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('preview'));
  await page.getByText('A density is not a point probability:',{exact:false}).waitFor();
  check('preview_concept_review_matches_continuous_models',true);
  await page.locator('#prob1-plot_example').evaluate(n=>n.selectize.setValue('normal65'));
  await page.getByRole('button',{name:'Load example',exact:true}).click();
  await page.getByText('The tail above 70 is 1-F(70), about 0.0478.',{exact:false}).waitFor();
  check('preview_visual_works_without_quiz',await page.locator('#prob1-mean_norm').inputValue()==='65'&&!await page.locator('#prob1-practice').evaluate(n=>n.open));
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('core'));await settle();
  check('no_visible_output_errors',await page.locator('.shiny-output-error:visible').count()===0);
  return {date:new Date().toLocaleDateString('en-CA',{timeZone:'Pacific/Auckland'}),url,total:cases.length,passed:cases.filter(x=>x.passed).length,cases,measurements};
}
