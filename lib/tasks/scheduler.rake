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
task :getvotes => :environment do
	require "open-uri"
	# SENADO
	doc = Nokogiri::HTML(open("http://www.senado.cl/appsenado/index.php?mo=sesionessala&ac=portada").read)
	doc.css('div[@class="bajada"] > a').each do |a|
		url="http://www.senado.cl"+a["href"].to_s
		puts url
		doc2=Nokogiri::HTML(open(url).read)
		project=nil
		remoteid=url.split("&boletin=")[1].to_s.strip
		unless project=Project.where(:remoteid=>remoteid).first
			project=Project.new(:remoteid=>url.split("&boletin=")[1].to_s.strip)
		end
		if project!=nil
			puts "RECOLECTANDO VOTOS EN EL SENADO PARA PROYECTO:"+project.remoteid+" ("+url+")"
			i=0
			doc2.css('tr[@class="tr-font-gris-short"]').each do |tr|
				if i>1
					y=0
					politician=nil
					vote=nil
					puts tr.text
					tr.css('td').each do |td|
						vote=Vote.new(:project_id=>project.id)
						if y==0
							firstname=td.text.split(",")[1].strip
							lastname=td.text.split(",")[0].strip.split(" ")[0]
							secondlastname=td.text.split(",")[0].strip.split(" ")[1]
							unless politician=Politician.new(:firstname=>firstname,:lastname=>lastname,:secondlastname=>secondlastname).save
								politician=Politician.where(:firstname=>firstname,:lastname=>lastname,:secondlastname=>secondlastname).first
							end
							vote.politician_id=politician.id
						end
						if y==1
							if(td.text.strip=="X")
								vote.score=1
							end
						end
						if y==2
							if(td.text.strip=="X")
								vote.score=-1
							end
						end
						if y==3
							if(td.text.strip=="X")
								vote.score=0
							end
						end
						y=y+1
					end
					vote.save
					puts vote.inspect
				end
				i=i+1
			end
		end
	end
end
task :updateremotedata => :environment do
	Project.all.each do |project|
		project.fetchdata
	end
end