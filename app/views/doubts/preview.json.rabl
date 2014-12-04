
object false 
  node(:preview) { 
    {
      source: :locker, 
      images: [ @dbt.scan ]
    }
  } 

  node(:a){ @dbt.id }
  node(:tagged){ @dbt.tagged? }
