"""Run after round1_audit.R, from repository root; Python standard library only."""
import json
import re
from fractions import Fraction as F
from pathlib import Path

banks = json.loads(Path('.local/course-review/banks.json').read_text(encoding='utf-8'))
rows = []
for q in banks['joint']:
    n = q['id']
    cells = re.findall(r'<td[^>]*>(.*?)</td>', q['table_ui'], re.S)
    def fraction(cell):
        match = re.search(r'\\(?:tfrac|frac)\{(\d+)\}\{(\d+)\}', cell)
        return F(int(match[1]), int(match[2])) if match else None
    vals = [fraction(c) for c in cells]
    # Q1-Q8 are row=y, column=x matrices; Q9 is an (x,y,mass) list;
    # Q10 is row=x, column=y and includes marginal placeholders.
    if n <= 6:
        width = 4 if n == 4 else 3
        masses = {(i % width, i // width): v for i, v in enumerate(vals)}
        total = sum(vals)
        answer = ({1: lambda: masses[1, 1], 2: lambda: masses[2, 1],
                   3: lambda: sum(v for (x, y), v in masses.items() if x == 1),
                   4: lambda: sum(v for (x, y), v in masses.items() if y == 0),
                   5: lambda: sum(v for (x, y), v in masses.items() if x > 0 and y <= 1),
                   6: lambda: sum(v for (x, y), v in masses.items() if x+y >= 3)}[n])()
        detail = 'Direct table calculation; invalid PMF must be redesigned before final answers are fixed.' if total != 1 else 'Direct table calculation.'
    elif n in (7, 8):
        known = sum(v for v in vals if v is not None)
        unknown_count = sum(v is None for v in vals)
        answer = (1-known)/unknown_count
        total = known + unknown_count * F(str(q['ans_val']))
        detail = f'Known mass={known}; {unknown_count} unknown cell(s). Total shown uses stored answer.'
    elif n == 9:
        coefficients = []
        for cell in cells[2::3]:
            coefficients.append(0 if cell == '0' else int(cell[:-1] or '1'))
        answer = F(1, sum(coefficients))
        total = None
        detail = f'Sum of k coefficients={sum(coefficients)}.'
    else:
        joint_cells = [row*4+col for row in range(3) for col in range(3)]
        known = sum(vals[i] for i in joint_cells if vals[i] is not None)
        answer = (1-known)/3
        total = None
        detail = f'Known joint mass={known}; three p cells. Marginals excluded.'
    rows.append(dict(question=n, expected_fraction=str(answer), expected=float(answer),
                     stored=q['ans_val'], answer_matches=abs(float(answer)-q['ans_val']) < 1e-10,
                     mass=str(total) if total is not None else None, detail=detail))
assert len(rows) == 10
assert rows[4]['expected_fraction'] == '1/2'
assert rows[5]['expected_fraction'] == '5/12'
Path('review/evidence/round1_joint.json').write_text(json.dumps(rows, indent=2)+'\n', encoding='utf-8')
print(json.dumps(rows, indent=2))
