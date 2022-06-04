import os, sys, time, json
import math

# input_file: 処理対象のディレクトリ
def divide_catalog(dir, size):
    with open(os.path.join(dir, 'catalog_0.catalog'), 'r') as catalog:
        lines = catalog.readlines()
    
    os.remove(os.path.join(dir, 'catalog_0.catalog'))

    for i in range(math.ceil(len(lines) / size)):
        print('{}: {} to {}'.format(i, (i * size), (i + 1) * size))
        target_lines = lines[i * size : (i + 1) * size]

        # catalogファイルを作成　
        with open(os.path.join(dir, 'catalog_{}.catalog'.format(i)), 'w') as catalog:
            catalog.writelines(target_lines)

        # catalog_manifestファイルを作成
        with open(os.path.join(dir, 'catalog_{}.catalog_manifest'.format(i)), 'w') as catalog_manifest:
            line_length = [len(line) for line in target_lines]
            data = {'created_at': time.time(), 'line_length': line_length, \
                'path': "catalog_{}.catalog".format(i), 'start_index': (i * size) }
            catalog_manifest.write(json.dumps(data))
        
    #manifestファイルを作成
    with open(os.path.join(dir, 'manifest.json'), 'r') as manifest:
        data = manifest.readlines()
        target_line = json.loads(data[4])
        target_line['paths'] = ['catalog_{}.catalog'.format(i) for i in range(math.ceil(len(lines) / size))]
        data[4] = json.dumps(target_line)
    with open(os.path.join(dir, 'manifest.json'), 'w') as manifest:
        manifest.writelines(data)


if __name__ == '__main__':
    input_dir = sys.argv[1]
    divide_catalog(input_dir, 1000)
