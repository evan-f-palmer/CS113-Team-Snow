createLove:
	cd src && zip -r game.love *
	cd ..
	mv src/game.love .

game.love: createLove

runLove: game.love
	love game.love