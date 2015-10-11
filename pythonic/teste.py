import pyttsx2,sys
engine = pyttsx2.init()
try:
	Query = sys.argv[1].split(':')[1].replace('_',' ')
except:
	Query = sys.argv[1]
engine.say(Query)
engine.runAndWait()
