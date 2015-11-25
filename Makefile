all:
	gcc -Wall ./ftplugin/python/delphi_timed_execution.c -o ./ftplugin/python/delphi_timed_execution.o

clean:
	rm ./ftplugin/python/*.o
	rm __*
