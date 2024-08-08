run "document_ingestion_tests" {
  command = plan

  module {
    source = "./examples/basic/modules/document-ingestion"
  }
}

run "networking_resources_tests" {
  command = plan

  module {
    source = "./examples/basic/modules/networking-resources"
  }
}

run "persistence_resources_tests" {
  command = plan

  module {
    source = "./examples/basic/modules/persistence-resources"
  }
}

run "question_answering_tests" {
  command = plan

  module {
    source = "./examples/basic/modules/question-answering"
  }
}

run "summarization_tests" {
  command = plan

  module {
    source = "./examples/basic/modules/summarization"
  }
}