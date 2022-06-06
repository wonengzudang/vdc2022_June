ssh -i "~/.ssh/<specify your secret key>" -T dockerusr@donkey-sim.roboticist.dev -p 22222 -- -c start_container -t <Specify yout docker hub tag> -r "'make Teamhirohaku_Yaminabe_Linear'"
