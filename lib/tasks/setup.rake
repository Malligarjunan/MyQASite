desc "Setup application"
task :bootstrap => [:environment, "setup:reset",
                    "setup:create_admin",
                    "setup:create_pages",
                    "setup:k12_group",
                    "setup:sample_questions"] do
end

#task :bootstrap => [:environment, "setup:create_group"] do
#end

desc "Upgrade"
task :upgrade => [:environment] do
end

namespace :setup do
    desc "Reset databases"
    task :reset => [:environment] do
        MongoMapper.connection.drop_database(MongoMapper.database.name)
    end
    
    desc "Reset admin password"
    task :reset_password => :environment do
        admin = User.find_by_login("admin")
        admin.encrypted_password = nil
        admin.password = "admin"
        admin.password_confirmation = "admin"
        admin.save
    end
    
    desc "Create the default group"
    task :default_group => [:environment] do
        default_tags = %w[technology business science politics religion
                               sports entertainment gaming lifestyle offbeat]
        
        subdomain = AppConfig.application_name.gsub(/[^A-Za-z0-9\s\-]/, "")[0,20].strip.gsub(/\s+/, "-").downcase
        default_group = Group.new(:name => AppConfig.application_name,
                              :domain => "50.19.122.131",
                              :subdomain => '50.19.122.131',
                              :description => "question-and-answer website",
                              :legend => "question and answer website",
                              :default_tags => default_tags,
                              :state => "active")
        
        default_group.save!
        if admin = User.find_by_login("admin")
            default_group.owner = admin
            default_group.add_member(admin, "owner")
        end
        default_group.logo =  File.open(RAILS_ROOT+"/public/images/logo.png")
        default_group.logo.extension = "png"
        default_group.logo.content_type = "image/png"
        default_group.save
    end
    
    desc "Create the K12 group"
    task :k12_group => [:environment] do
        default_tags = %w[cbse icse I II III IV V VI VII VIII IX X XI XII geometry fractions numbers decimals probability ratio proportion counting roman addition subtraction division multiplication exponential weight capacity units algebra calculus triangle square rectangle shapes polynomial age equations area perimeter diagonal volume percentage]
        
        subdomain = AppConfig.application_name.gsub(/[^A-Za-z0-9\s\-]/, "")[0,20].strip.gsub(/\s+/, "-").downcase
        k12_group = Group.new(:name => 'K12',
                              :domain => 'ec2-50-19-122-131.compute-1.amazonaws.com',
                              :subdomain => 'ec2-50-19-122-131.compute-1.amazonaws.com',
                              :domain => 'ec2-50-19-122-131.compute-1.amazonaws.com',
                              :description => " ",
                              :legend => "Website for Students",
                              :default_tags => default_tags,
                              :state => "active",
                              :enable_latex => true)
        
        k12_group.save!
        if admin = User.find_by_login("admin")
            k12_group.owner = admin
            k12_group.add_member(admin, "owner")
        end
        k12_group.logo =  File.open(RAILS_ROOT+"/public/images/logo.png")
        k12_group.logo.extension = "png"
        k12_group.logo.content_type = "image/png"
        k12_group.save
    end
    
    desc "Create default widgets"
    task :create_widgets => :environment do
        default_group = Group.find_by_domain(AppConfig.domain)
        
        if AppConfig.enable_groups
            default_group.widgets << GroupsWidget.new
        end
        default_group.widgets << UsersWidget.new
        default_group.widgets << BadgesWidget.new
        default_group.save!
    end
    
    desc "Create admin user"
    task :create_admin => [:environment] do
        admin = User.new(:login => "admin", :password => "admins",
                                        :password_confirmation => "admins",
                                        :email => "malligarjunan@gmail.com",
                                        :role => "admin")
        
        admin.save!
    end
    
    desc "Create user"
    task :create_user => [:environment] do
        user = User.new(:login => "user", :password => "user123",
                                      :password_confirmation => "user123",
                                      :email => "user@example.com",
                                      :role => "user")
        user.save!
    end
    
    desc "Sample questions"
    task :sample_questions => [:environment] do
        question1 = Question.new
        question1.title = 'What are the mathematics cources I can do after +2?'
        question1.body = 'What are the mathematics cources I can do after +2?'
        question1.views_count = 2
        question1.language = 'en'
        question1.tags = 'MATHS,XII,'
        question1.wiki = '0'
        group = Group.find_by_name("K12")
        question1.group = group
        
        admin = User.find_by_login("admin")
        question1.user = admin
        question1.save!
        answer1 = Answer.new( :user => admin,
                                  :body => 'BSc and MSc courses in Mathematics and Statistics are offered by most universities in India . Increasingly integrated courses for students of Mathematics are becoming popular',
                                  :language => 'en')
        answer1.votes_count = 0
        answer1.votes_average = 0
        answer1.flags_count = 0
        answer1.group_id = question1.group_id
        question1.answers << answer1
        question1.answer_added!
        
        question2 = Question.new
        question2.title = 'CBSE Class IX paper Pattern'
        question2.body = 'What is the marking distribution of Maths CBSE Class IX?'
        question2.views_count = 2
        question2.language = 'en'
        question2.tags = 'MATHS,IX,CBSE,'
        question2.wiki = '0'
        question2.group = group
        question2.user = admin
        question2.save!
        answer2 = Answer.new( :user => admin,
                                  :body => 'I. NUMBER SYSTEMS   6, II. ALGEBRA 20,  III. COORDINATE GEOMETRY    6, IV. GEOMETRY    22, V. MENSURATION  14, VI. STATISTICS AND PROBABILITY  22, TOTAL   80, INTERNAL ASSESSMENT 20',
                                  :language => 'en')
        answer2.votes_count = 0
        answer2.votes_average = 0
        answer2.flags_count = 0
        answer2.group_id = question1.group_id
        question2.answers << answer2
        question2.answer_added!
        
        question2 = Question.new
        question2.title = 'CBSE Guess paper for 2011'
        question2.body = 'What is the marking distribution of Maths CBSE Class IX?'
        question2.views_count = 2
        question2.language = 'en'
        question2.tags = 'CBSE,'
        question2.wiki = '0'
        question2.group = group
        question2.user = admin
        question2.save!
        answer2 = Answer.new( :user => admin,
                                  :body => 'If you want to check CBSE Guess Paper or CBSE Previous year question paper click http://cbse.learnhub.com',
                                  :language => 'en')
        answer2.votes_count = 0
        answer2.votes_average = 0
        answer2.flags_count = 0
        answer2.group_id = question1.group_id
        question2.answers << answer2
        question2.answer_added!
        
        question2 = Question.new
        question2.title = 'Essays: How Long is Too Long'
        question2.body = "We have all heard the phrase 'quality over quantity' but where is the happy medium? Certainly a couple paragraphs won't give the amount of quality needed to achieve the best mark possible. Does this phrase get ruled out when assignments specify how long the essay is supposed to be? Does the required number of words dictate the quality involved in the essays we write?"
        question2.views_count = 2
        question2.language = 'en'
        question2.tags = 'ESSAY,ENGLISH,'
        question2.wiki = '0'
        question2.group = group
        question2.user = admin
        question2.save!
        answer2 = Answer.new( :user => admin,
                                  :body => 'Here is a link to a handy thesis and outline tool, you might find it helpful in your essay preparation. http://www.tommarch.com/electraguide/',
                                  :language => 'en')
        answer2.votes_count = 0
        answer2.votes_average = 0
        answer2.flags_count = 0
        answer2.group_id = question1.group_id
        question2.answers << answer2
        question2.answer_added!
        
        
    end
    
    desc "Create pages"
    task :create_pages => [:environment] do
        Dir.glob(RAILS_ROOT+"/db/fixtures/pages/*.markdown") do |page_path|
            basename = File.basename(page_path, ".markdown")
            title = basename.gsub(/\.(\w\w)/, "").titleize
            language = $1
            
            body = File.read(page_path)
            
            puts "Loading: #{title.inspect} [lang=#{language}]"
            Group.find_each do |group|
                if Page.count(:title => title, :language => language, :group_id => group.id) == 0
                    Page.create(:title => title, :language => language, :body => body, :user_id => group.owner, :group_id => group.id)
                end
            end
        end
    end
    
    desc "Reindex data"
    task :reindex => [:environment] do
        class Question
            def update_timestamps
            end
        end
        
        class Answer
            def update_timestamps
            end
        end
        
        class Group
            def update_timestamps
            end
        end
        
        $stderr.puts "Reindexing #{Question.count} questions..."
        Question.find_each do |question|
            question._keywords = []
            question.rolling_back = true
            question.save(:validate => false)
        end
        
        $stderr.puts "Reindexing #{Answer.count} answers..."
        Answer.find_each do |answer|
            answer._keywords = []
            answer.rolling_back = true
            answer.save(:validate => false)
        end
        
        $stderr.puts "Reindexing #{Group.count} groups..."
        Group.find_each do |group|
            group._keywords = []
            group.save(:validate => false)
        end
    end
end

