import json, sys
from pathlib import Path

path = Path('assets/recipes.json')
data = json.loads(path.read_text(encoding='utf-8'))
errors=[]
valid_categories={'Quick Meals','Healthy Bowls','Desserts','Traditional Indian Dishes'}
valid_cuisines={'South Indian','North Indian','East Indian','West Indian','International'}
ids=set(); names=set(); missing=[]
for i,r in enumerate(data,1):
 where=f'recipe {i} ({r.get("name")})'
 if r.get('id') in ids: errors.append(f'{where}: duplicate id')
 ids.add(r.get('id'))
 key=r.get('name','').strip().casefold()
 if key in names: errors.append(f'{where}: duplicate name')
 names.add(key)
 if r.get('category') not in valid_categories: errors.append(f'{where}: invalid category')
 if r.get('cuisine') not in valid_cuisines: errors.append(f'{where}: invalid cuisine')
 if r.get('foodType') not in {'Vegetarian','Non-Vegetarian'}: errors.append(f'{where}: invalid food type')
 if not r.get('ingredients'): errors.append(f'{where}: no ingredients')
 steps=r.get('instructions',[])
 if not (6<=len(steps)<=12) or any(not isinstance(s,str) or len(s.split())<3 for s in steps): errors.append(f'{where}: instructions need 6–12 meaningful non-empty steps')
 if len({s.strip().casefold() for s in steps}) != len(steps): errors.append(f'{where}: repeated instruction step')
 if not (isinstance(r.get('prepTimeMinutes'),int) and r['prepTimeMinutes']>0 and isinstance(r.get('cookTimeMinutes'),int) and r['cookTimeMinutes']>=0 and r.get('totalTimeMinutes')==r['prepTimeMinutes']+r['cookTimeMinutes']): errors.append(f'{where}: invalid or inconsistent times')
 if not r.get('ingredients') or any(not isinstance(x,str) or not x.strip() for x in r['ingredients']): errors.append(f'{where}: invalid ingredient entry')
 if not isinstance(r.get('nutrition'),dict) or not all(k in r['nutrition'] and r['nutrition'][k]>0 for k in ['calories','proteinGrams','carbsGrams','fatGrams']): errors.append(f'{where}: invalid nutrition')
 img=r.get('image',r.get('imageUrl',''))
 if r.get('id','').startswith('ind_') and (not img.startswith('assets/images/recipes/') or Path(img).exists() is False): missing.append(img)
indian_count=sum(r.get('id','').startswith('ind_') for r in data)
if indian_count<120: errors.append(f'only {indian_count} Indian recipes (need 120)')
sequences=[tuple(s.strip().casefold() for s in r.get('instructions',[])) for r in data]
if len(set(sequences)) != len(sequences): errors.append('duplicate full instruction sequence')
if errors:
 print('\n'.join(errors)); sys.exit(1)
Path('assets/images/recipes/MISSING_PHOTOS.txt').write_text('\n'.join(missing) + '\n', encoding='utf-8')
print(f'PASS: {indian_count} Indian recipes (+ {len(data)-indian_count} preserved legacy recipe), unique IDs/names, fields and categories validated.')
print(f'PHOTO STATUS: {len(missing)} dish-matched local photos missing; see assets/images/recipes/MISSING_PHOTOS.txt.')
for image in missing: print(f'MISSING PHOTO: {image}')
