ssh -i "~/.ssh/<Enter Your Private Key>" -T dockerusr@donkey-sim.roboticist.dev -p 22222 -- -c start_container -t 0.1 -r "'make test_run'"
