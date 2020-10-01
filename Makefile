all :
	chmod +x *.sh
	cp *.sh $(BIGHORNS)/bin/

pawsey : all
	rsync -avP *.sh galaxy:~/smart/bin/
	rsync -avP *.py galaxy:~/smart/bin/
	rsync -avP pawsey/*.sh galaxy:~/smart/bin/pawsey/ 			
	rsync -avP pawsey/*.py galaxy:~/smart/bin/pawsey/
	