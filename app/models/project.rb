# encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	has_many :updates
	has_many :comments
	has_many :votes
	attr_accessible :remoteid, :score, :title, :updated_at, :submitted_at, :last_discussed, :status, :statusdescription
	validates_uniqueness_of :remoteid
	def fetchdata
		self.update_attributes(:updated_at=>Time.now)
		url="http://www.senado.cl/wspublico/tramitacion.php?boletin="+self.remoteid.split("-")[0]
		doc = Nokogiri::XML(open(url))
		puts "BUSCANDO INFO PARA PROYECTO #"+self.id.to_s+" "+self.remoteid+" ("+url+")"
		p=doc.xpath("//proyectos/proyecto")
		submissiondate=Date.strptime(p.xpath("descripcion/fecha_ingreso").inner_text,'%d/%m/%Y').to_datetime;
		self.update_attributes(
			:title=>p.xpath("descripcion/titulo").inner_text,
			:submitted_at=>submissiondate
			);
		self.update_attributes(:last_discussed=>submissiondate) if self.last_discussed==nil
		i=0;
		doc.xpath("//proyectos/proyecto/tramitacion/tramite").map do |t|
			discussiondate=Date.strptime(t.xpath("FECHA").inner_text,'%d/%m/%Y').to_datetime;
			update=Update.new(
				:session=>t.xpath("SESION").inner_text,
				:date=>discussiondate,
				:description=>t.xpath("DESCRIPCIONTRAMITE").inner_text,
				:statusdescription=>t.xpath("ETAPDESCRIPCION").inner_text,
				:project_id=>self.id,
				:chamber=>t.xpath("CAMARATRAMITE").inner_text
				)

			self.update_attributes(:last_discussed=>discussiondate) if discussiondate>self.last_discussed
			puts "+ update: "+update.inspect if update.save
		
		end
		# buscando etapa de la tramitacion, esto debería ser mas lindo pero la gente del senado olvidó ponerlo en su API
		url="http://sil.senado.cl/cgi-bin/sil_proyectos.pl?"+self.remoteid
		doc = Nokogiri::HTML(open(url).read)
		tds=doc.css('td[@bgcolor="#f6f6f6"]')
		subetapa=tds[8].text.strip
		etapa=tds[7].text.strip
		puts "etapa: "+etapa+" subetapa: "+subetapa
		if subetapa.length>1
			self.update_attributes(:statusdescription=>subetapa)
		else
			self.update_attributes(:statusdescription=>etapa)
		end
		self.update_attributes(:status=>1) if(etapa=="Tramitación terminada" && subetapa[0..2]=="Ley")
		self.update_attributes(:status=>2) if(self.statusdescription=="Retirado")
		self.update_attributes(:status=>2) if(self.statusdescription=="Archivado")
		puts self.inspect
	end
	def statusname
		if self.updates.length>0
			self.updates.order("date").last.statusdescription
		else
			"Ingresado"
		end
	end
	def statuscolor
		statuscolors=["default","success","important"]
		return statuscolors[self.status]
	end
	def announce
		bitly=Bitly.new("donemiterio", "R_3d38b50740671572e08dfd08f8cd4741")
		Twitter.update(truncate(self.title, :length=>120)+" "+bitly.shorten('http://camarapublica.cl/projects/'+self.id.to_s).short_url)
	end
	def updatescore
		score=0
		self.votes.each do |v|
			score=score+v.score
		end
		self.update_attributes(:score=>score)
		return score
	end
end