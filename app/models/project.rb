#encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	include PgSearch
	include ActionView::Helpers::TextHelper
	has_many :updates
	has_many :comments
	has_many :votes
	has_many :authorships
	has_many :congressmen, through: :authorships
	attr_accessible :remoteid, :score, :title, :updated_at, :submitted_at, :last_discussed, :status, :statusdescription
	pg_search_scope :search, :against => [:title, :statusdescription, :remoteid],:ignoring => :accents, :order_within_rank => "last_discussed ASC, id DESC"
	validates_uniqueness_of :remoteid

	def xpath_to_text(xpath)
		xpath.inner_text.strip
	end
	def xpath_to_date(xpath)
		Date.strptime(xpath_to_text(xpath), '%d/%m/%Y').to_datetime
	end

	def fetchdata
		# project info
		puts "updating project #{self.remoteid} ("+self.submitted_at.to_s+")"
		url = "http://www.senado.cl/wspublico/tramitacion.php?boletin=" + self.remoteid.split("-")[0]
		doc = Nokogiri::XML(open(url))
		p_xpath = doc.xpath("//proyectos/proyecto")
		self.update_attributes(:submitted_at=>xpath_to_date(p_xpath.xpath("descripcion/fecha_ingreso")))
		self.update_attributes(:title=>xpath_to_text(p_xpath.xpath("descripcion/titulo")))
		self.update_attributes(:statusdescription=>xpath_to_text(p_xpath.xpath("descripcion/etapa")))
		p_status=xpath_to_text(p_xpath.xpath("descripcion/estado")).strip
		status=0
		case
		when p_status=="Archivado" then status=2
		when p_status=="Retirado" then status=2
		when p_status=="Inconstitucional" then status=2
		when p_status=="Rechazado" then status=2
		when p_status=="Publicado" then status=1
		end
		self.update_attributes(:status=>status)
		# updates
		discussed=self.submitted_at
		tramites_xpath = doc.xpath("//proyectos/proyecto/tramitacion/tramite")
		tramites_xpath.each do |tramite_xpath|
			update=Update.new(
				date: xpath_to_date(tramite_xpath.xpath("FECHA")),
				session: xpath_to_text(tramite_xpath.xpath("SESION")),
				description: xpath_to_text(tramite_xpath.xpath("DESCRIPCIONTRAMITE")),
				statusdescription: xpath_to_text(tramite_xpath.xpath("ETAPDESCRIPCION")),
				chamber: xpath_to_text(tramite_xpath.xpath("CAMARATRAMITE")),
				project_id: self.id
				)
			if update.date>discussed
				discussed=update.date
			end
			if update.save
				puts "new update: "+update.inspect
			end
		end
		# authors
		authors_xpath = doc.xpath("//proyectos/proyecto/autores/autor")
		authors_xpath.each do |author_xpath|
			fullname=xpath_to_text(author_xpath.xpath("PARLAMENTARIO"))
			names=fullname.split(",")[1].strip
			surnames=fullname.split(",")[0].strip
			unless @congressman=Congressman.where(:names=>names,:surnames=>surnames).first
				@congressman=Congressman.new(:names=>names,:surnames=>surnames)
				@congressman.save
			end
			Authorship.new(:project_id=>self.id, :congressman_id=>@congressman.id).save
		end
		self.update_attributes(:last_discussed=>discussed)
	end
	def fetchstatus
		# deprecated, at last
		doc = Nokogiri::HTML open "http://www.senado.cl/wspublico/tramitacion.php?boletin=" + self.remoteid.split("-")[0]
		tds = doc.css('td[@bgcolor="#f6f6f6"]') # LOL

		subetapa = tds[8].text.strip
		etapa    = tds[7].text.strip
		logger.info "etapa: #{etapa} subetapa: #{subetapa}"

		period = {
			statusdescription: subetapa.blank? ? etapa : subetapa
		}

		period[:status] = \
		case
		when etapa == "Tramitación terminada" && subetapa[0..2] == "Ley"  then 1
		when etapa == "Tramitación terminada" && subetapa[0..3] == "D.S." then 1
		when period[:statusdescription] == "Retirado"  then 2
		when period[:statusdescription] == "Archivado" then 2
		else 0
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
		return statuscolors[self.status]
	end
	def scorecolor
		if self.score>0
			"success"
		elsif self.score<0
			"important"
		else
			"default"
		end
	end
	def announce
		if Rails.env.production?
			begin
				bitly=Bitly.new("donemiterio", "R_3d38b50740671572e08dfd08f8cd4741")
				Twitter.update(truncate(self.title, :length=>120)+" "+bitly.shorten('http://camarapublica.cl/projects/'+self.remoteid).short_url)
			rescue
				puts "Twitter Error"
			end
		end
	end
	def updatescore
		score=0
		self.votes.each do |v|
			score=score+v.score
		end
		self.update_attributes(:score=>score)
		return score
	end
	def documenturl
		doc = Nokogiri::HTML open "http://sil.senado.cl/cgi-bin/sil_proyectos.pl?" + self.remoteid
		button = doc.css('a[@onmouseout="ima_of(\'tra\')"]')
		"http://minecraft.mego.cl/catdoc.php?id="+button.attribute("href").text.split("?")[1].split(",")[0]
	end
end