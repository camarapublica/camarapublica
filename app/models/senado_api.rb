require 'open-uri'
class SenadoAPI
  def fetch_project(remote_id)
		url = project_url(remote_id)
		doc = Nokogiri::XML(open(url))
		logger.info "BUSCANDO INFO PARA PROYECTO ##{remote_id} (#{url})"
		p_xpath = doc.xpath("//proyectos/proyecto")
    
    submitted_at_xpath = p_xpath.xpath("descripcion/fecha_ingreso")
		logger.info "fecha de ingreso #{xpath_to_text(submitted_at_xpath)}"
		
    project = {
		  title: xpath_to_text(p_xpath.xpath("descripcion/titulo")),
      submitted_at: xpath_to_date(submitted_at_xpath)
		}
    project = project.merge fetch_period(remote_id)
    
    tramites_xpath = doc.xpath("//proyectos/proyecto/tramitacion/tramite")
		tramites = tramites_xpath.map do |tramite_xpath|
      {
        # at some point we should have better naming for this variables
        date: xpath_to_date(tramite_xpath.xpath("FECHA")),
        session: xpath_to_text(tramite_xpath.xpath("SESION")),
        description: xpath_to_text(tramite_xpath.xpath("DESCRIPCIONTRAMITE")),
        statusdescription: xpath_to_text(tramite_xpath.xpath("ETAPDESCRIPCION")),
        chamber: xpath_to_text(tramite_xpath.xpath("CAMARATRAMITE")),
        # project_id
      }
		end
    project[:tramites] = tramites
    project
  end
  
  
  # buscando etapa de la tramitacion, esto debería ser mas lindo pero la gente del senado olvidó ponerlo en su API
  def fetch_period(remote_id)
		doc = Nokogiri::HTML open period_url(remote_id)
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
    
    period
  end
  
  private
    def project_url(remote_id)
      "http://www.senado.cl/wspublico/tramitacion.php?boletin=" + remote_id.split("-")[0]
    end
    def period_url(remote_id)
      "http://sil.senado.cl/cgi-bin/sil_proyectos.pl?#{remote_id}"
    end
    
    def logger
      @logger ||= Logger.new(STDOUT)
    end
end