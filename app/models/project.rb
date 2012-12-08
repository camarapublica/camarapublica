# encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	has_many :updates
	attr_accessible :remoteid, :score, :title, :updated_at, :submitted_at, :last_discussed
	validates_uniqueness_of :remoteid
	def fetchdata
		url="http://www.senado.cl/wspublico/tramitacion.php?boletin="+self.remoteid.split("-")[0]
		doc = Nokogiri::XML(open(url))
		puts "BUSCANDO INFO PARA PROYECTO "+self.remoteid+" ("+url+")"
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
			if update.save
				puts "+ update: "+update.inspect
			else
				puts "- duplicate: "+update.inspect
			end
			i=i+1;
		end
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
	end
end