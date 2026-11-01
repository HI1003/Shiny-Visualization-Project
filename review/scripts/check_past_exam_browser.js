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
    if(!await link.isVisible())await page.getByRole('link',{name:'bars icon',exact:true}).click();
    await link.click();
  };
  const modules=[['overview','prob1',null],['joint','joint1','chart-area icon Joint Distribution'],
    ['conditional','cond1','chart-bar icon Conditional Distribution'],['expectation','exp1','chart-line icon Expectation']];
  await page.goto('http://127.0.0.1:7130/');await page.setViewportSize({width:1266,height:900});
  await page.getByRole('button',{name:'play icon Review STATS125 concepts',exact:true}).click();
  await page.waitForFunction(()=>document.activeElement.id==='prob1-theory');
  for(const [module,prefix,link] of modules){
    await page.setViewportSize({width:1266,height:900});await settle();if(link)await nav(link);
    await page.locator('#'+prefix+'-theory').waitFor();await settle();
    check(module+'_practice_closed_by_default',!await page.locator('#'+prefix+'-practice').evaluate(n=>n.open));
    check(module+'_concepts_then_visuals_then_optional',await page.evaluate(prefix=>{
      const t=document.getElementById(prefix+'-theory'),e=document.getElementById(prefix+'-explorer'),p=document.getElementById(prefix+'-practice');
      return !!(t.compareDocumentPosition(e)&4)&&!!(e.compareDocumentPosition(p)&4);
    },prefix));
    await page.getByRole('link',{name:'Past-exam questions (optional)',exact:true}).click();
    await page.locator('#'+prefix+'-practice .learning-exam-source').waitFor();
    const q=expected.questions.find(q=>q.module===module);
    const meta=await page.locator('#'+prefix+'-question_meta').innerText();
    check(module+'_verified_year_question_source_and_adaptation',meta.includes(q.reference)&&meta.includes(q.year.toString())&&meta.includes(q.question)&&meta.includes(q.adapted?'Adapted presentation':'Original extract; formatting only'));
    check(module+'_one_verified_extract_only',(await page.locator('#'+prefix+'-practice .practice-progress').innerText()).includes('0 / 1'));
    for(let i=0;i<3;i++){
      await page.locator('#'+prefix+'-check').click();await settle();
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
      await page.waitForFunction(({prefix,note})=>document.getElementById(prefix+'-pmf_example_note').innerText.includes(note),{prefix,note:q.tableNote});
      check(module+'_exam_table_caption_matches',(await page.locator('#'+prefix+'-pmf_example_note').innerText()).includes(q.tableNote));
      check(module+'_exact_exam_table_rendered',await page.locator('#'+prefix+'-workbench').evaluate((n,rows)=>{
        const text=n.innerText;
        return rows.every(r=>text.includes(String(r.x))&&text.includes(String(r.y)));
      },q.rows));
    }else{
      for(const graph of expected.graphs){
        await page.locator('#'+prefix+'-plot_choice_'+q.reference).evaluate((n,v)=>n.selectize.setValue(v),graph.key);
        await page.locator('#'+prefix+'-explore_example').click();await settle();
        await page.waitForFunction(g=>document.getElementById('prob1-example_note').innerText.includes(g.note),graph);
        check('overview_'+graph.key+'_linked_parameters',await page.evaluate(g=>{
          const input=document.getElementById('prob1-lambda');
          return document.getElementById('prob1-dist').selectize.getValue()===g.dist&&Math.abs(Number(input.value)-g.mean)<1e-10;
        },graph));
        await page.waitForFunction(g=>document.getElementById('prob1-sel_text').innerText.startsWith('x = '+g.x+'\n'),graph);
        check('overview_'+graph.key+'_linked_selected_point',(await page.locator('#prob1-sel_text').innerText()).startsWith('x = '+graph.x+'\n'));
      }
    }
    for(const width of [1600,1266,900,390]){
      await page.setViewportSize({width,height:900});await settle();
      const m=await page.locator('#'+prefix+'-practice').evaluate(n=>({viewport:innerWidth,pageWidth:document.documentElement.scrollWidth,
        clipped:Array.from(n.querySelectorAll('p,label,strong')).filter(e=>e.getClientRects().length&&!e.querySelector('.MathJax,.MathJax_SVG')&&e.scrollWidth>e.clientWidth+3).length}));
      measurements.push({module,...m});check(module+'_'+width+'_source_and_answers_fit',m.pageWidth<=width+1&&m.clipped===0);
      if(width===1266||width===390){await page.locator('#'+prefix+'-practice').scrollIntoViewIfNeeded();await page.screenshot({path:'output/playwright/exam_'+module+'_'+width+'.png'});}
    }
  }
  await page.setViewportSize({width:1266,height:900});await settle();
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('preview'));await settle();
  check('preview_does_not_fall_back_to_original_questions',(await page.locator('#exp1-practice_status').innerText()).includes('No verified past-exam extract'));
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('core'));await settle();
  await page.locator('.learning-optional-progress > summary').click();
  await page.waitForFunction(()=>document.getElementById('learning_progress').innerText.includes('4 / 4'));
  check('core_progress_retained',(await page.locator('#learning_progress').innerText()).includes('4 / 4'));
  const response=await page.request.get('http://127.0.0.1:7130/.local/past-exams/bank.json');
  check('private_bank_not_available_as_static_download',response.status()===404);
  await nav('house icon Home');await page.getByRole('button',{name:'play icon Review STATS125 concepts',exact:true}).click();
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('preview'));await settle();
  await page.getByRole('link',{name:'Past-exam questions (optional)',exact:true}).click();
  await page.waitForFunction(()=>document.getElementById('prob1-practice_status').innerText.includes('No verified past-exam extract'));
  check('overview_preview_has_valid_empty_practice_panel',await page.locator('#prob1-practice_status').isVisible());
  await page.locator('#learning_path').evaluate(n=>n.selectize.setValue('core'));await settle();
  await page.locator('#prob1-practice > summary').click();
  return {date:new Date().toISOString(),passed:cases.filter(c=>c.passed).length,total:cases.length,cases,measurements,
    screenshotPolicy:'Exam screenshots remain in ignored output/playwright only.'};
}
