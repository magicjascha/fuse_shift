require "test_helper"

feature "Register" do
  
  def setup
    #logged in
    @contact_persons_email = "maja.the.contact@mail.de"
    contact_person = create_confirmed_contact_person(@contact_persons_email)
    visit login_path
    fill_in 'Email', with: @contact_persons_email
    click_button 'Submit'
  end
  
  scenario "Register" do
    registration = build(:registration_input)
    page.must_have_content("You registered 0 people")
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    page.must_have_content "You registered #{registration.name} for the festival"
    page.must_have_content("You registered 1 person")
  end
  
  scenario "Registration without name is invalid" do
    registration = build(:registration_input)
    page.must_have_content("You registered 0 people")
    fill_in 'Email', with: registration.email
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    page.must_have_content "Name can't be blank"
    page.must_have_content("You registered 0 people")
  end
  
  scenario "session fills names of associated records" do
    registrations_count = 5#must be bigger 1, session overflow when bigger 5
    names = []
    registrations_count.times do 
      registration = build(:registration_input, :sequence)
      names.push(registration.name)
      fill_in 'Name', with: registration.name
      fill_in 'Email', with: registration.email
      select_date_and_time '21,June,15', :from => 'Arrival'
      select_date_and_time '27,June,15', :from => 'Departure'
      click_button 'Submit'
      click_link 'New Registration'
    end
    page.must_have_content("You registered #{registrations_count} people")
    page.assert_selector('td', text: "#{names[0]}")
    page.assert_selector('td', text: "#{names[registrations_count-1]}")#name from factory-sequence in tabledata
  end
  
  scenario "session fills in edit-form" do
    #make a registration
    registration = build(:registration)
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    #go to edit
    click_link 'edit'
    #check if it's the right page
    assert_equal "/registrations/#{registration.hashed_email}", current_path
    page.assert_selector('h1', text: "Edit registration with ID")
    assert_equal find_field('Name').value, registration.name
  end
  
  scenario "delete session" do
    #register
    registration = build(:registration)
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    #check session-fill in on edit-page
    visit "/registrations/#{registration.hashed_email}"
    assert_equal find_field('Name').value, registration.name
    #delete session
    click_link 'Delete Cookie-Data'
    #check logout
    assert_equal login_path, current_path
    #login
    fill_in 'Email', with: @contact_persons_email
    click_button 'Submit'
    assert_no_text registration.name
  end
  
end
