Dear #{@student.account.first_name}
%p
  Your teacher / course instructor has posted a new homework assignment 
  for you to do
%p
  You would need to log-in into your Gradians.com account. Then, 
  %ul
    %li
      Click on the tab called <b>Inbox</b>
    %li
      Look for a quiz called <b>#{@quiz.name}</b>
    %li
      Download the worksheet PDF and print-it out
%p
  Do your work in the worksheet and then <b>either</b> return the completed 
  worksheets to your instructor or scan and upload the assignment yourself
%p
  At any rate, <b>good luck with the quiz!</b>. Do the best that you can and do 
  not worry about the result
%p
  <b>Gradians Support Team</b>
