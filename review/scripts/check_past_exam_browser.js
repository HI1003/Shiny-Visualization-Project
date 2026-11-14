// Inject only the locally verified fixture into an ignored copy before using CLI run-code.
// Neither the fixture nor screenshots containing examination content belong in Git.
async page => {
  const expected = null;
  if (!expected) throw new Error('Run an ignored copy with the private exam fixture injected.');
  page.setDefaultTimeout(30000);
  const cases=[], measurements=[];
  const check=(name,passed)=>cases.push({name,passed:!!passed});
  const settle=async()=>{
    await page.evaluate(()=>window.__examStable={key:'',at:performance.now()});
    await page.waitForFunction(()=>{
      const r=document.querySelector('.content-wrapper').getBoundingClientRect();
      const key=[innerWidth,Math.round(r.width),Math.round(r.x),document.documentElement.scrollWidth].join(',');
      const s=window.__examStable;
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
    await link.click();
  };
  const modules=[['overview','prob1',null],['joint','joint1','chart-area icon Joint Distribution'],
    ['conditional','cond1','chart-bar icon Conditional Distribution'],['expectation','exp1','chart-line icon Expectation']];
  await page.goto('http://127.0.0.1:7130/');await page.setViewportSize({width:1266,height:900});
  await page.waitForFunction(()=>window.Shiny?.shinyapp?.isConnected());await settle();
  await nav('lightbulb icon Overview');
  await page.locator('#prob1-theory').waitFor();
  for(const [module,prefix,link] of modules){
    await page.setViewportSize({width:1266,height:900});await settle();if(link)await nav(link);
    await page.locator('#'+prefix+'-theory').waitFor();await settle();
    check(module+'_practice_closed_by_default',!await page.locator('#'+prefix+'-practice').evaluate(n=>n.open));
    check(module+'_concepts_then_visuals_then_optional',await page.evaluate(prefix=>{
      const t=document.getElementById(prefix+'-theory'),e=document.getElementById(prefix+'-explorer'),p=document.getElementById(prefix+'-practice');
      return !!(t.compareDocumentPosition(e)&4)&&!!(e.compareDocumentPosition(p)&4);
    },prefix));
    check(module+'_learning_steps_are_1_2_3',await page.locator('#'+prefix+'-theory').evaluate(n=>{
      const titles=Array.from(n.closest('.learning-module').querySelectorAll(
        '.learning-card-title,.learning-optional-practice > summary'));
      const numbers=titles.map(t=>/^([123])\.\s/.exec(t.textContent.trim())).filter(Boolean).map(m=>Number(m[1]));
      return JSON.stringify(numbers)===JSON.stringify([1,2,3]);
    }));
    await page.getByRole('link',{name:'Past-exam questions (optional)',exact:true}).click();
    await page.locator('#'+prefix+'-practice .learning-exam-source').waitFor();
    const q=expected.questions.find(q=>q.module===module);
    const meta=await page.locator('#'+prefix+'-question_meta').innerText();
    check(module+'_verified_year_question_source_and_adaptation',meta.includes(q.reference)&&meta.includes(q.year.toString())&&meta.includes(q.question)&&meta.includes(q.adapted?'Adapted presentation':'Original extract; formatting only'));
    check(module+'_one_verified_extract_only',(await page.locator('#'+prefix+'-practice .practice-progress').innerText()).includes('0 / 1'));
    for(let i=0;i<3;i++){
      const previousFeedback=await page.locator('#'+prefix+'-feedback').innerHTML();
      await page.locator('#'+prefix+'-check').click();await settle();
      await page.waitForFunction(({prefix,previousFeedback})=>{
        const feedback=document.getElementById(prefix+'-feedback');
        return feedback.querySelector('.alert')&&feedback.innerHTML!==previousFeedback;
      },{prefix,previousFeedback});
      check(module+'_feedback_stage_'+(i+1),await page.locator('#'+prefix+'-feedback .alert').count()===1);
    }
    for(const f of q.fields){
      const target=page.locator('#'+prefix+'-answer_'+q.reference+'_'+f.key);
      if(f.kind==='choice')await target.evaluate((n,v)=>n.selectize.setValue(v),f.expected);
      else await target.fill(String(f.expected));
    }
    await page.locator('#'+prefix+'-check').click();
    await page.locator('#'+prefix+'-feedback .alert-success').waitFor();
    check(module+'_reference_answer_accepted_in_browser',true);
    await page.locator('#'+prefix+'-check').click();await settle();
    check(module+'_repeat_does_not_increment',(await page.locator('#'+prefix+'-practice .practice-progress').innerText()).includes('1 / 1'));
    if(module!=='overview'){
      await page.locator('#'+prefix+'-explore_example').click();await settle();
      await page.waitForFunction(prefix=>document.activeElement.id===prefix+'-explorer',prefix);
      check(module+'_exam_link_returns_focus_to_explorer',true);
      await page.waitForFunction(({prefix,note})=>document.getElementById(prefix+'-pmf_example_note').innerText.includes(note),{prefix,note:q.tableNote});
      check(module+'_exam_table_caption_matches',(await page.locator('#'+prefix+'-pmf_example_note').innerText()).includes(q.tableNote));
      await page.waitForFunction(({prefix,rows})=>{
        const table=document.querySelector('#'+prefix+'-joint_table_html table');if(!table)return false;
        const mathText=n=>{
          const scripts=Array.from(n.querySelectorAll('script[type^="math/tex"]'));
          return (scripts.length?scripts.map(s=>s.textContent).join(''):n.textContent).replace(/\u2212/g,'-').replace(/\s/g,'');
        };
        const ys=Array.from(table.querySelectorAll('thead th')).slice(1).map(n=>/^y=([-\d.]+)$/.exec(mathText(n))).filter(Boolean).map(m=>Number(m[1]));
        const actual=[];
        for(const tr of table.querySelectorAll('tbody tr')){
          const header=tr.querySelector('th'),match=header&&/^x=([-\d.]+)$/.exec(mathText(header));if(!match)continue;
          const cells=Array.from(tr.querySelectorAll('td[data-number-value]'));
          ys.forEach((y,i)=>{if(cells[i])actual.push({x:Number(match[1]),y,p:Number(cells[i].dataset.numberValue)});});
        }
        return actual.length===rows.length&&rows.every(r=>actual.some(a=>a.x===r.x&&a.y===r.y&&Math.abs(a.p-r.p_value)<1e-12));
      },{prefix,rows:q.rows});
      check(module+'_exact_exam_table_rendered',true);
    }else{
      for(const graph of expected.graphs){
        await page.locator('#'+prefix+'-plot_choice_'+q.reference).evaluate((n,v)=>n.selectize.setValue(v),graph.key);
        await page.locator('#'+prefix+'-explore_example').click();await settle();
        await page.waitForFunction(g=>document.getElementById('prob1-dist').value===g.dist&&
          Math.abs(Number(document.getElementById('prob1-lambda').value)-g.mean)<1e-10&&
          Math.abs(document.getElementById('prob1-pmf_plot')?.data?.[0]?.y[0]-Math.exp(-g.mean))<1e-12,graph);
        check('overview_'+graph.key+'_linked_parameters',await page.evaluate(g=>{
          const input=document.getElementById('prob1-lambda');
          return document.getElementById('prob1-dist').selectize.getValue()===g.dist&&Math.abs(Number(input.value)-g.mean)<1e-10;
        },graph));
        await page.waitForFunction(mean=>{
          const number=document.querySelector('[data-parameter-slider="prob1-lambda"]');
          const slider=jQuery(document.getElementById('prob1-lambda')).data('ionRangeSlider');
          return Math.abs(Number(number.value)-mean)<1e-10&&Math.abs(slider.result.from-mean)<1e-10&&
            number.getAttribute('aria-invalid')==='false';
        },graph.mean);
        check('overview_'+graph.key+'_number_and_slider_match_exam',true);
        await page.waitForFunction(mean=>{
          const trace=document.getElementById('prob1-cdf_plot')?.data?.[0];
          return trace&&Math.abs(trace.y[trace.x.indexOf(0)]-Math.exp(-mean))<1e-12;
        },graph.mean);
        check('overview_'+graph.key+'_cdf_matches_exam_parameters',true);
        await page.waitForFunction(g=>document.getElementById('prob1-pmf_plot')?.data?.[0]?.x.includes(g.x),graph);
        check('overview_'+graph.key+'_example_point_on_plot',await page.locator('#prob1-pmf_plot').evaluate((n,x)=>n.data[0].x.includes(x),graph.x));
      }
    }
    for(const width of [1600,1266,900,390]){
      await page.setViewportSize({width,height:900});await settle();
      const m=await page.locator('#'+prefix+'-practice').evaluate(n=>({viewport:innerWidth,pageWidth:document.documentElement.scrollWidth,
        clipped:Array.from(n.querySelectorAll('p,label,strong')).filter(e=>e.getClientRects().length&&!e.querySelector('.MathJax,.MathJax_SVG')&&e.scrollWidth>e.clientWidth+3).length}));
      measurements.push({module,...m});check(module+'_'+width+'_source_and_answers_fit',m.pageWidth<=width+1&&m.clipped===0);
      const heading=await page.locator('#'+prefix+'-theory').evaluate(n=>{
        const root=n.closest('.learning-module'),p=root.querySelector('.learning-module-heading p');
        const range=document.createRange();range.selectNodeContents(p);
        return {paragraphWidth:p.getBoundingClientRect().width,
          availableWidth:p.parentElement.getBoundingClientRect().width,
          lines:new Set(Array.from(range.getClientRects()).map(r=>Math.round(r.top))).size,
          explicitBreaks:p.querySelectorAll('br').length,
          clippedTitles:Array.from(root.querySelectorAll('.learning-card-title,.learning-optional-practice > summary'))
            .filter(t=>t.scrollWidth>t.clientWidth+3).length};
      });
      check(module+'_'+width+'_headings_use_available_space',
        Math.abs(heading.paragraphWidth-heading.availableWidth)<2&&heading.explicitBreaks===0&&
        heading.clippedTitles===0&&(width!==1600||heading.lines===1));
      if(width===1266||width===390){await page.locator('#'+prefix+'-practice').scrollIntoViewIfNeeded();await page.screenshot({path:'output/playwright/exam_'+module+'_'+width+'.png'});}
    }
  }
  await page.setViewportSize({width:1266,height:900});await settle();
  await nav('lightbulb icon Overview');
  await page.getByRole('combobox',{name:'Learning path',exact:true}).click();
  await page.getByRole('option',{name:'Optional STATS210 preview',exact:true}).click();await settle();
  await page.locator('#prob1-practice').waitFor({state:'hidden'});
  check('overview_preview_hides_empty_practice_panel',!await page.locator('#prob1-practice').isVisible());
  check('overview_preview_hides_practice_navigation',!await page.getByRole('link',{name:'Past-exam questions (optional)',exact:true}).isVisible());
  let retained=true;
  for(const [,prefix,link] of modules.slice(1)){
    await nav(link);
    await page.getByRole('link',{name:'Past-exam questions (optional)',exact:true}).click();
    await page.waitForFunction(id=>document.getElementById(id+'-practice_status').innerText.includes('1 / 1'),prefix);
    retained=retained&&(await page.locator('#'+prefix+'-practice_status').innerText()).includes('1 / 1');
  }
  await nav('lightbulb icon Overview');
  await page.locator('#prob1-learning_path').evaluate(n=>n.selectize.setValue('core'));await settle();
  await page.waitForFunction(()=>document.getElementById('prob1-practice_status').innerText.includes('1 / 1'));
  retained=retained&&(await page.locator('#prob1-practice_status').innerText()).includes('1 / 1');
  check('per_module_progress_retained_without_extra_home_or_sidebar_controls',retained&&await page.locator('#learning_progress,.learning-optional-progress,#start_core_practice,#start_joint_practice,.main-sidebar [id$="learning_path"]').count()===0);
  const response=await page.request.get('http://127.0.0.1:7130/.local/past-exams/bank.json');
  check('private_bank_not_available_as_static_download',response.status()===404);
  await page.locator('#prob1-practice > summary').click();
  return {date:new Date().toISOString(),passed:cases.filter(c=>c.passed).length,total:cases.length,cases,measurements,
    screenshotPolicy:'Exam screenshots remain in ignored output/playwright only.'};
}
