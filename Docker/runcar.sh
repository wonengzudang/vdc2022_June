#!/bin/bash
# run pln model using the docker gpu image (adapted from Toni's script)

#cmd_line="python3 /root/myrace/manage.py drive --model=/root/myrace/models/mymodel.h5"
cmd_line="python3 /root/race7/manage.py drive --model=/root/race7/models/warren_pln5.h5"

echo "Executing in the docker (gpu image):"
echo $cmd_line

docker run -it --rm --network host \
  hirohaku21/test:latest\
  bash -c "cd /root/race7 && $cmd_line"
