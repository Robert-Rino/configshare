acc1 = CreateAccount.call(
  username: 'soumya.ray', email: 'sray@nthu.edu.tw', password: 'mypassword')

acc2 = CreateAccount.call(
  username: 'lee123', email: 'lee@nthu.edu.tw', password: 'randompassword')

proj11 = CreateProjectForOwner.call(
  owner_id: acc1.id, name: 'Soumya Project',
  repo_url: 'http://github.com/soumya/project.git')

doc11 = CreateConfigurationForProject.call(
  project: proj11, filename: 'config_env.rb',
  document: "this is the first line\nthis is the second line",
  description: 'environmental configurations for test, development envs')

doc12 = CreateConfigurationForProject.call(
  project: proj11, filename: 'environments.ini', document: '---')

proj12 = CreateProjectForOwner.call(owner_id: acc1.id, name: 'Config Project')
doc21 = CreateConfigurationForProject.call(
  project: proj12, filename: 'credentials.json', document: 'username: password')

proj21 = acc2.add_owned_project(name: 'Lee\'s Project')
acc1.add_project(proj21)
proj22 = acc2.add_owned_project(name: 'Lee\'s Solo Project')

puts 'Database seeded!'
DB.tables.each { |table| puts "#{table} --> #{DB[table].count}" }
