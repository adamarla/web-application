object false
node(:bundles) {
 @bundles.map{ |b|
    {
      id: b.uid,
      questions: b.bundle_questions.collect{ |bq|
        {
          uid: bq.question.uid,
          label: bq.label
        }
      }
    }
  } 
}
