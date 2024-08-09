run "document_ingestion_tests" {
  command = plan

  module {
    source = "./tests/modules/document-ingestion"
  }
}

run "networking_resources_tests" {
  command = plan

  module {
    source = "./tests/modules/networking-resources"
  }
}

run "persistence_resources_tests" {
  command = plan

  module {
    source = "./tests/modules/persistence-resources"
  }
}

run "question_answering_tests" {
  command = plan

  module {
    source = "./tests/modules/question-answering"
  }
}

run "summarization_tests" {
  command = plan

  module {
    source = "./tests/modules/summarization"
  }
}