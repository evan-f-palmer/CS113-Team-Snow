createLove:
	cd src && zip -r game.love *
	cd ..
	mv src/game.love .

runLove: createLove
	love game.love