#coding=utf-8
import urllib2
import os,sys
#diretório do mod
path = sys.argv[1]
try:
	#lingua
	Lang = sys.argv[2]
	#texto para ser falado
	Query = sys.argv[3].split(':')[1].replace('_',' ')
	#ir para lá
	os.chdir(path)
	#url requisitada
	#urln = 'http://127.0.0.1:8000/googletalk.ogg'
	
	urln = 'https://translate.google.com.br/translate_tts?ie=UTF-8&q=\''+Query+'\'&tl='+Lang+'&total=1&idx=0&textlen=2&tk=576592&client=t&prev=input&ttsspeed=0.24'
	print urln
	request = urllib2.Request(urln)
	request.add_header('User-agent', 'OpenAnything/1.0 +http://diveintopython.org/')
	opener = urllib2.build_opener()
	#Lê a resposta
	audio = opener.open(request).read()
	
	#salva o audio
	file_x = open('sounds/pythonic_googletalk.ogg','wb')
	file_x.write(audio)
	file_x.close()
except Exception,err:
	print 'ooops',Exception,err
