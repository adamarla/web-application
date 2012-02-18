
jQuery ->
  $('#new-teacher > form:first').isHappy {
    fields : {
      '#teacher_name': {
        required : true,
        message : 'need the full name here'
      }
    }
  }

  $('#new-school > form').isHappy {
    fields: {
      '#school_name': {
        required: true,
        message: 'required'
      }
    }
  }
