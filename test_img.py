import pypandoc
import tempfile
import os

with tempfile.NamedTemporaryFile(suffix='.md', mode='w', delete=False, encoding='utf-8') as f:
    f.write('![img](temp_images/dummy.png)\n')
    name = f.name
print('Temp file:', name)
try:
    pypandoc.convert_file(name, 'pdf', outputfile='test_img.pdf')
    print('Success')
except Exception as e:
    print('Error:', e)
finally:
    os.remove(name)
