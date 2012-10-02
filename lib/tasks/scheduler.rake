task :getprojects => :environment do
	require "open-uri"
	doc = Nokogiri::HTML(open("http://sil.senado.cl/cgi-bin/sil_ultproy.pl").read)
	puts "BUSCANDO NUEVOS PROYECTOS DE LEY"
	doc.css('td[@class="TEXTpais"]').each do |td|
		remoteid=td.text.strip.chop.chop
		if project=Project.new(:remoteid=>remoteid).save
			puts "NUEVO PROYECTO:"+remoteid+". BIENVENIDO!"
		end
	end
end
task :updateremotedata => :environment do
	Project.all.each do |project|
		project.fetchdata
	end
end