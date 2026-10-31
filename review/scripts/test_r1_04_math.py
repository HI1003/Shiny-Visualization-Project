"""Independent exact arithmetic on the rendered bank, using Python standard library.
Run after test_r1_04.R. Optional args: bank.json report.json.
"""
import ast
import html
import json
import re
import sys
from datetime import date
from fractions import Fraction as F
from pathlib import Path

bank_file = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".local/r1_04_bank.json")
destination = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("review/evidence/r1_04_math.json")
banks = json.loads(bank_file.read_text(encoding="utf-8"))

def clean(value):
    value = re.sub(r"<script.*?</script>", "", value, flags=re.S)
    return html.unescape(re.sub(r"<[^>]*>", "", value)).strip().replace(r"\(", "").replace(r"\)", "")

def numeric(value):
    value = re.sub(r"\\(?:tfrac|frac)\{(-?\d+)\}\{(\d+)\}", r"(\1/\2)", value)
    value = value.replace(r"\times", "*")
    for token in (r"\quad", r"\,", r"\Big", r"\big", r"\left", r"\right"):
        value = value.replace(token, "")
    node = ast.parse(value.strip().rstrip("."), mode="eval").body
    def evaluate(node):
        if isinstance(node, ast.Constant) and type(node.value) in (int, float):
            return F(str(node.value))
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.USub, ast.UAdd)):
            return (-1 if isinstance(node.op, ast.USub) else 1) * evaluate(node.operand)
        if isinstance(node, ast.BinOp):
            left, right = evaluate(node.left), evaluate(node.right)
            if isinstance(node.op, ast.Add): return left + right
            if isinstance(node.op, ast.Sub): return left - right
            if isinstance(node.op, ast.Mult): return left * right
            if isinstance(node.op, ast.Div): return left / right
        raise ValueError("Non-arithmetic expression")
    return evaluate(node)

def affine(value):
    value = clean(value)
    if value == "?": return F(0), 1
    match = re.fullmatch(r"(\d*)([akp])", value)
    if match: return F(0), int(match[1] or "1")
    return numeric(value), 0

def check_question(q):
    n = q["id"]
    prompt = re.sub(r"\s+", "", clean(q["question"])).replace(r"\,", "")
    goals = {1:"P(X=1,Y=1)",2:"P(X=2,Y=1)",3:"f_X(1)",4:"f_Y(0)",
             5:r"P(X>0,Y\le1)",6:r"P(X+Y\ge3)"}
    if n in goals:
        question_valid = goals[n] in prompt
    elif n == 7:
        question_valid = "missingprobability" in prompt
    else:
        parameter_name = {8:"a",9:"k",10:"p"}[n]
        question_valid = bool(re.search(r"\\\("+parameter_name+r"(?:\\ge0)?\\\)", q["question"]))
    table = q["table_ui"]
    cells = re.findall(r"<td[^>]*>(.*?)</td>", table, re.S)
    if n == 9:
        grid = {(int(numeric(clean(cells[i]))), int(numeric(clean(cells[i+1])))): affine(cells[i+2])
                for i in range(0, len(cells), 3)}
    else:
        header = re.search(r"<thead>(.*?)</thead>",table,re.S)[1]
        body = re.search(r"<tbody>(.*?)</tbody>",table,re.S)[1]
        column_axis, row_axis = ("y","x") if n == 10 else ("x","y")
        columns = [int(value) for value in re.findall(column_axis+r"=(\d+)",header)]
        assert columns and len(columns)==len(set(columns))
        grid = {}
        for row in re.findall(r"<tr[^>]*>(.*?)</tr>",body,re.S):
            label = re.search(r"<th[^>]*>[^<]*"+row_axis+r"=(\d+)[^<]*</th>",row)
            if label is None: continue  # Q10's final marginal row.
            row_value = int(label[1])
            row_cells = re.findall(r"<td[^>]*>(.*?)</td>",row,re.S)
            assert len(row_cells)==len(columns)+(1 if n==10 else 0)
            for column,cell in zip(columns,row_cells):
                key = (row_value,column) if n==10 else (column,row_value)
                assert key not in grid
                grid[key] = affine(cell)
        assert len(grid)==(8 if n==4 else 9)
    known = sum((a for a,b in grid.values()), F(0))
    coefficient = sum(b for a,b in grid.values())
    parameter = (1-known)/coefficient if coefficient else None
    mass = {key: a+b*(parameter or 0) for key,(a,b) in grid.items()}
    total = sum(mass.values())
    table_valid = total == 1 and all(v >= 0 for v in mass.values())
    if n <= 6:
        predicates = {
            1: lambda x,y: x==1 and y==1,
            2: lambda x,y: x==2 and y==1,
            3: lambda x,y: x==1,
            4: lambda x,y: y==0,
            5: lambda x,y: x>0 and y<=1,
            6: lambda x,y: x+y>=3}
        selected = [key for key in grid if predicates[n](*key)]
        expected = sum((mass[key] for key in selected), F(0))
        hinted = {tuple(map(int,p)) for p in re.findall(r"\((\d+),\s*(\d+)\)", q["hint2"])}
        selection_valid = hinted == set(selected)
        explained = [tuple(map(int,p)) for p in re.findall(r"f_\{X,Y\}\((\d+),\s*(\d+)\)", q["solution"])]
        selection_valid = selection_valid and sorted(explained) == sorted(selected)
    else:
        expected = parameter
        selected = []
        selection_valid = True
    answer_valid = (F(q["ans_frac"]) == expected and abs(float(expected)-q["ans_val"]) < 1e-12)
    equations_checked, errors = 0, []
    symbol = {7:"p",8:"a",9:"k",10:"p"}.get(n)
    for field in ("question","hint1","hint2","solution"):
        formulas = re.findall(r"\\\((.*?)\\\)|\\\[(.*?)\\\]", q[field], re.S)
        for pair in formulas:
            formula = pair[0] or pair[1]
            formula = formula.split(r"\approx")[0]
            if symbol:
                formula = re.sub(r"(\d*)"+symbol+r"\b", lambda m: (m[1] or "1")+"*("+str(expected)+")", formula)
            for chain in re.split(r"\\Rightarrow|\\implies", formula):
                computed = []
                for part in chain.split("="):
                    try: computed.append(numeric(part))
                    except (ValueError,SyntaxError,TypeError): continue
                    except ZeroDivisionError:
                        errors.append({"field":field,"formula":formula,"error":"zero denominator"})
                if len(computed)>1:
                    equations_checked += 1
                    if any(value != computed[0] for value in computed[1:]):
                        errors.append({"field":field,"formula":formula,"values":[str(v) for v in computed]})
    # Every new solution has at least one actual numeric equality, so parsing cannot pass vacuously.
    equations_valid = equations_checked > 0 and not errors
    return dict(question=n, passed=question_valid and table_valid and answer_valid and selection_valid and equations_valid,
        question_valid=question_valid,
        table_valid=table_valid,total_mass=str(total),expected_fraction=str(expected),
        stored_fraction=q["ans_frac"],answer_valid=answer_valid,selection_valid=selection_valid,
        equations_checked=equations_checked,equations_valid=equations_valid,equation_errors=errors,
        selected_cells=selected,completed_cells={f"{x},{y}":str(v) for (x,y),v in mass.items()})

assert numeric(r"\tfrac{1}{8} + \tfrac{1}{8}") == F(1,4)
assert numeric(r"\tfrac{1}{8} + \tfrac{1}{8}") != numeric(r"\tfrac{1}{8}")
assert len(banks) == 10 and [q["id"] for q in banks] == list(range(1,11))
results = [check_question(q) for q in banks]
report = dict(issue="R1-04",date=date.today().isoformat(),total=10,
              passed=sum(row["passed"] for row in results),questions=results)
destination.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(f'{report["passed"]}/10 exact table/answer/explanation checks passed.')
for row in results:
    if not row["passed"]: print(json.dumps(row,ensure_ascii=False))
if report["passed"] != 10: raise SystemExit(1)
