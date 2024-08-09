run "document_ingestion_tests" {
  command = plan

  module {
    source = "./tests/test-modules/document-ingestion"
  }
}

run "networking_resources_tests" {
  command = plan

  module {
    source = "./tests/test-modules/networking-resources"
  }
}

run "persistence_resources_tests" {
  command = plan

  module {
    source = "./tests/test-modules/persistence-resources"
  }
}

run "question_answering_tests" {
  command = plan

  module {
    source = "./tests/test-modules/question-answering"
  }
}

run "summarization_tests" {
  command = plan

  module {
    source = "./tests/test-modules/summarization"
  }
}