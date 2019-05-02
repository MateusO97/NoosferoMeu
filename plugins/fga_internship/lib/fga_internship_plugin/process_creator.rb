module FgaInternshipPlugin::ProcessCreator
	def create_documents
    fi = FgaInternshipPlugin::Document.new(
      :name => "Formulário de Inscrição",
      :doc_type => "form",
      :view_permission => ["student", "coordinator"],
      :write_permission => ["student"],
      :phase => "pre-application"
    )
    fi.save

    tc = FgaInternshipPlugin::Document.new(
      :name => "Termo de Compromisso",
      :doc_type => "file",
      :view_permission => ["student", "company", "supervisor", "coordinator"],
      :write_permission => ["student", "company", "supervisor", "coordinator"],
      :phase => "application"
    )
    tc.save

    pa = FgaInternshipPlugin::Document.new(
      :name => "Plano de Atividades",
      :doc_type => "form",
      :view_permission => ["student", "company", "supervisor", "coordinator"],
      :write_permission => ["student", "company", "supervisor", "coordinator"],
      :phase => "application"
    )
    pa.save

    he = FgaInternshipPlugin::Document.new(
      :name => "Histórico Escolar",
      :doc_type => "file",
      :view_permission => ["student", "coordinator"],
      :write_permission => ["student"],
      :phase => "application"
    )
    he.save

    rt = FgaInternshipPlugin::Document.new(
      :name => "Relatório Técnico",
      :doc_type => "file",
      :view_permission => ["student", "supervisor", "coordinator"],
      :write_permission => ["student"],
      :phase => "in-progress"
    )
    rt.save

    a1 = FgaInternshipPlugin::Document.new(
      :name => " Plano de Atividades de Estágio + Parecer do Orientador",
      :doc_type => "form",
      :view_permission => ["student", "supervisor", "coordinator"],
      :write_permission => ["student", "supervisor"],
      :phase => "in-progress"
    )
    a1.save

    a2 = FgaInternshipPlugin::Document.new(
      :name => "Avaliação de Desempenho de Estagiário",
      :doc_type => "form",
      :view_permission => ["company", "coordinator"],
      :write_permission => ["company"],
      :phase => "evaluation"
    )
    a2.save

    a3 = FgaInternshipPlugin::Document.new(
      :name => "Ficha de Avaliação de Estágio",
      :doc_type => "form",
      :view_permission => ["supervisor"],
      :write_permission => ["supervisor", "coordinator"],
      :phase => "evaluation"
    )
    a3.save

    a4 = FgaInternshipPlugin::Document.new(
      :name => "Avaliação de Estágio e de Concedente pelo Aluno",
      :doc_type => "form",
      :view_permission => ["student", "coordinator"],
      :write_permission => ["student"],
      :phase => "evaluation"
    )
    a4.save

    return documents = [fi, tc, pa, he, rt, a1, a2, a3, a4]
  end

  def create_checklists
    documents = create_documents

    checklists = []

    documents.each do |document|
      checklist = FgaInternshipPlugin::Checklist.new(
        :name => "#{document.name}",
        :link => "#",
        :checked => false
      )
      checklist.document = document

      checklist.save

      checklists << checklist
    end

    return checklists
  end

  def create_process
    community = Community.find(params[:community_id])
    student = current_user.person
    
    process = FgaInternshipPlugin::InternshipProcess.new

    process.checklists = create_checklists
    process.community_id = community
    process.student_id = student

    process.save

    return process
  end
end
