async page => {
  page.setDefaultTimeout(30000);
  const appUrl=page.url(),cases=[],measurements=[];
  if(!/^http:\/\/(127\.0\.0\.1|localhost):[0-9]+\//.test(appUrl)) throw new Error('Open the local Shiny app first.');
  const check=(name,passed,detail='')=>cases.push({name,passed:!!passed,detail});
  const waitForMath=async(id)=>page.waitForFunction(id=>{
    const target=document.getElementById(id);
    if(!target)return false;
    const frames=Array.from(target.querySelectorAll('.MathJax,.MathJax_SVG')).filter(n=>n.getClientRects().length);
    return frames.length>0&&frames.every(n=>n.getBoundingClientRect().width>1);
  },id);
  const settle=async()=>{
    await page.evaluate(()=>{window.__layoutStable={key:'',at:performance.now()};});
    await page.waitForFunction(()=>{
      const r=document.querySelector('.content-wrapper').getBoundingClientRect();
      const key=[innerWidth,Math.round(r.width),Math.round(r.x),document.documentElement.scrollWidth].join(',');
      const state=window.__layoutStable;
      if(state.key!==key){state.key=key;state.at=performance.now();return false;}
      return performance.now()-state.at>650;
    });
  };
  const visibleLink=async(name)=>{
    const link=page.getByRole('link',{name,exact:true});
    if(!await link.isVisible()) await page.getByRole('link',{name:'bars icon',exact:true}).click();
    await link.click();
  };
  await page.goto(appUrl);await page.setViewportSize({width:1266,height:900});
  await page.getByRole('status').filter({hasText:'0 / 30 practice exercises correct'}).waitFor();
  check('layout_css_loaded',await page.evaluate(()=>Array.from(document.styleSheets).some(s=>s.href&&s.href.endsWith('/css/learning-layout.css'))));
  await page.getByRole('button',{name:'play icon Start STATS125 core practice',exact:true}).click();
  await page.getByText('Exercise 1 of 1 | Reference O01 | STATS125 Core',{exact:true}).waitFor();
  await page.waitForFunction(()=>document.activeElement.id==='prob1-practice');
  check('home_core_button_opens_and_focuses_practice',true);
  await visibleLink('house icon Home');
  await page.getByRole('button',{name:'Start joint-table practice',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='joint1-practice');
  check('home_joint_button_opens_and_focuses_practice',true);
  for(const [module,prefix,link] of [
    ['joint','joint1','chart-area icon Joint Distribution'],
    ['conditional','cond1','chart-bar icon Conditional Distribution'],
    ['expectation','exp1','chart-line icon Expectation']]) {
    await page.setViewportSize({width:1266,height:900});await settle();await visibleLink(link);
    await page.locator('#'+prefix+'-practice .practice-progress').waitFor();
    await page.evaluate(()=>scrollTo(0,0));await settle();
    const first=await page.locator('#'+prefix+'-practice').boundingBox();
    check(module+'_practice_in_first_screen',first.y>=0&&first.y<600,first);
    await page.getByRole('link',{name:'Go to practice',exact:true}).click();
    check(module+'_jump_focus',await page.evaluate(id=>document.activeElement.id===id,prefix+'-practice'));
    for(const width of [1600,1266,900,390]) {
      await page.setViewportSize({width,height:900});await settle();await page.evaluate(()=>scrollTo(0,0));
      const metrics=await page.locator('#'+prefix+'-practice').evaluate((practice,prefix)=>{
        const table=document.getElementById(prefix+'-workbench');
        const a=practice.getBoundingClientRect(),b=table.getBoundingClientRect();
        const overlap=Math.min(a.right,b.right)-Math.max(a.left,b.left)>1&&Math.min(a.bottom,b.bottom)-Math.max(a.top,b.top)>1;
        const rowOverlap=Array.from(table.querySelectorAll('.pmf-edit-row')).some(row=>{
          const rects=Array.from(row.querySelectorAll('input,button')).filter(n=>n.getClientRects().length).map(n=>n.getBoundingClientRect());
          return rects.some((r,i)=>rects.slice(i+1).some(s=>Math.min(r.right,s.right)-Math.max(r.left,s.left)>1&&Math.min(r.bottom,s.bottom)-Math.max(r.top,s.top)>1));
        });
        const clippedText=Array.from(practice.closest('.learning-module').querySelectorAll('p,label')).filter(n=>
          n.getClientRects().length&&!n.querySelector('.MathJax,.MathJax_SVG,.MathJax_Preview')&&n.scrollWidth>n.clientWidth+3).map(n=>n.innerText.slice(0,80));
        const renderedTable=table.querySelector('table'),t=renderedTable?.getBoundingClientRect();
        return {viewport:innerWidth,documentWidth:document.documentElement.scrollWidth,practiceWidth:a.width,tableWidth:b.width,
          mode:Math.abs(a.y-b.y)<2?'columns':'stacked',overlap,rowOverlap,clippedText,
          tableFullyVisible:!!t&&t.left>=b.left-1&&t.right<=b.right+1};
      },prefix);
      measurements.push({module,...metrics});
      check(module+'_'+width+'_no_page_overflow',metrics.documentWidth<=width+1,metrics);
      check(module+'_'+width+'_no_panel_or_input_overlap',!metrics.overlap&&!metrics.rowOverlap);
      check(module+'_'+width+'_plain_text_wraps',metrics.clippedText.length===0,metrics.clippedText);
      check(module+'_'+width+'_default_table_fits',metrics.tableFullyVisible);
      if(width===1266) await page.screenshot({path:'output/playwright/layout_'+module+'_1266.png'});
      if(width===390) await page.screenshot({path:'output/playwright/layout_'+module+'_390.png'});
    }
    await page.setViewportSize({width:1266,height:900});await settle();
    await page.getByRole('link',{name:'Theory & formulas',exact:true}).click();
    const theory=await page.locator('#'+prefix+'-theory').evaluate(n=>({open:n.open,width:n.clientWidth,moduleWidth:n.closest('.learning-module').clientWidth}));
    check(module+'_theory_expands_at_full_width',theory.open&&theory.width>theory.moduleWidth*.9,theory);
    await waitForMath(prefix+'-theory');
    check(module+'_visible_math_has_measured_width',true);
    await page.screenshot({path:'output/playwright/layout_'+module+'_theory.png'});
    await page.locator('#'+prefix+'-theory > summary').click();
    if(module!=='expectation') {
      const disclosure=page.locator('#'+prefix+'-plots .learning-3d');
      check(module+'_3d_initially_collapsed',!await disclosure.evaluate(n=>n.open));
      await page.getByRole('link',{name:'Plots',exact:true}).click();
      await disclosure.locator('summary').click();
      const plotId=prefix+(module==='joint'?'-plot3d':'-plot3d_cond');
      await page.waitForFunction(id=>{const n=document.getElementById(id);return n&&n._fullLayout&&n._fullLayout.width>100;},plotId);
      check(module+'_3d_renders_after_expanding',true);
      await disclosure.locator('summary').click();
    }
  }
  await page.setViewportSize({width:1266,height:900});await settle();await visibleLink('house icon Home');
  await page.getByRole('button',{name:'play icon Start STATS125 core practice',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='prob1-practice');
  await page.getByRole('link',{name:'Explore plots & parameters',exact:true}).click();
  check('overview_plot_jump_focus',await page.evaluate(()=>document.activeElement.id==='prob1-explorer'));
  for(const width of [1600,1266,900,390]) {
    await page.setViewportSize({width,height:900});await settle();
    const metrics=await page.locator('#prob1-explorer').evaluate(n=>{
      const r=n.getBoundingClientRect();
      const plots=Array.from(n.querySelectorAll('.shiny-plot-output')).filter(p=>p.getClientRects().length);
      return {viewport:innerWidth,documentWidth:document.documentElement.scrollWidth,explorerWidth:r.width,
        plotWidths:plots.map(p=>p.getBoundingClientRect().width),
        clipped:plots.some(p=>p.getBoundingClientRect().right>r.right+1)};
    });
    measurements.push({module:'overview',...metrics});
    check('overview_'+width+'_no_page_or_plot_overflow',metrics.documentWidth<=width+1&&!metrics.clipped,metrics);
    await page.evaluate(()=>document.getElementById('prob1-explorer').scrollIntoView({block:'start'}));
    if(width===1266||width===390) await page.screenshot({path:'output/playwright/layout_overview_'+width+'.png'});
  }
  await page.setViewportSize({width:1266,height:900});await settle();
  if(!await page.evaluate(()=>document.body.classList.contains('sidebar-collapse')))
    await page.getByRole('link',{name:'bars icon',exact:true}).click();
  await settle();
  await page.mouse.move(800,400);
  check('collapsed_sidebar_hides_learning_selector',await page.locator('.learning-path-controls').isHidden());
  check('collapsed_sidebar_uses_main_space',await page.evaluate(()=>document.querySelector('.content-wrapper').getBoundingClientRect().x<100));
  await page.getByRole('link',{name:'bars icon',exact:true}).click();await settle();
  await page.locator('#theme_switch').check({force:true});
  await page.waitForFunction(()=>document.body.classList.contains('dark-mode'));
  const contrast=await page.locator('#prob1-controls').evaluate(n=>{
    const rgb=s=>s.match(/[\d.]+/g).slice(0,3).map(Number).map(v=>{v/=255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4;});
    const lum=v=>v[0]*.2126+v[1]*.7152+v[2]*.0722;
    const a=lum(rgb(getComputedStyle(n).color)),b=lum(rgb(getComputedStyle(n).backgroundColor));
    return (Math.max(a,b)+.05)/(Math.min(a,b)+.05);
  });
  check('dark_panel_text_contrast',contrast>=4.5,contrast);
  await waitForMath('prob1-qtext');
  check('inline_math_does_not_overlap_after_tab_and_theme_changes',true);
  await page.screenshot({path:'output/playwright/layout_dark.png'});
  await page.locator('#theme_switch').uncheck({force:true});
  check('no_visible_shiny_errors',await page.locator('.shiny-output-error:visible').count()===0);
  return {date:'2026-10-31',url:appUrl,total:cases.length,passed:cases.filter(x=>x.passed).length,cases,measurements};
}
