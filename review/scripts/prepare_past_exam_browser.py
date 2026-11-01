"""Create an ignored browser fixture from the private bank; embeds no exam content."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[2]
bank = json.loads((root / '.local/past-exams/bank.json').read_text(encoding='utf-8'))
questions = []
for question in bank['questions']:
    source = bank['sources'][question['source_id']]
    entry = dict(module=question['module'], reference=question['key'], year=source['year'],
                 question=question['source_question'], adapted=question['adapted'], fields=question['fields'])
    if 'pmf_example' in question:
        table = bank['tables'][question['pmf_example']]
        entry.update(tableNote=table['note'], rows=table['rows'])
    questions.append(entry)
fixture = dict(questions=questions, graphs=[
    dict(key=key, dist=graph['dist'], mean=graph['inputs']['lambda'], x=graph['x'], note=graph['note'])
    for key, graph in bank['graphs'].items()])
script = (root / 'review/scripts/check_past_exam_browser.js').read_text(encoding='utf-8')
destination = root / '.local/exam-selection/browser_private.js'
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(script.replace('const expected = null;', 'const expected = ' + json.dumps(fixture) + ';'),
                       encoding='utf-8', newline='\n')
print('Private browser fixture prepared under .local; do not commit it.')
