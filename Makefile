run:
	lua $(filter-out $@,$(MAKECMDGOALS))
	
runLove:
	love $(filter-out $@,$(MAKECMDGOALS))