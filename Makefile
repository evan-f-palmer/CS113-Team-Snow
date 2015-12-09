Name="Infinistar"
Windows="-windows32"

createLove:
	cd src && zip -r $(Name).love *
	cd ..
	mv src/$(Name).love .

$(Name).love: createLove

runLove: $(Name).love
	love $(Name).love
	
createWindows: createLove
	cp loveWindows/exe/love.exe .
	cat love.exe $(Name).love > $(Name).exe
	mkdir -p "$(Name)$(Windows)"
	cp loveWindows/dll/* "$(Name)$(Windows)/."
	mv "$(Name).exe" "$(Name)$(Windows)/."
	zip -r "$(Name)$(Windows)".zip "$(Name)$(Windows)"
	rm -rf "$(Name)$(Windows)"