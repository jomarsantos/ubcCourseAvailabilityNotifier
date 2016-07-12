require 'rubygems'
require 'mechanize'
require 'net/smtp'


FROM_EMAIL = "from@from.com" # TODO: INSERT sender email here
PASSWORD = "password" # TODO: INSERT sender password here
TO_EMAIL = "to@to.com" # TODO: INSERT receiver email here

def main()
	courses = [
		# TODO: ADD/DELETE courses here
		{ subject: "CPSC",
			course: "322",
		 	section: "101"
		},
		{ subject: "CPSC",
			course: "322",
		 	section: "201"
		}
	]

	linkMain = "https://courses.students.ubc.ca/cs/main?pname=subjarea&tname=subjareas&req=5&dept="
	linkCourse = "&course="
	linkSection = "&section="

	agent = Mechanize.new
	availableCourses = []
	for course in courses
		link = linkMain + course[:subject] + linkCourse + course[:course] + linkSection + course[:section]
		page = agent.get(link)
		remaining = page.at("td:contains('Total Seats Remaining:')").parent
		remaining = remaining.at("td[align='left'] strong").text
		if remaining != "0"
			course[:link] = link
			course[:remaining] = remaining
			availableCourses.push(course)
		end
	end

	email(availableCourses)
end

def email(availableCourses)
	if availableCourses.length != 0
		time = Time.new
		msgstr = "From: Course Checker <#{FROM_EMAIL}>\n"
		msgstr += "To: Student <#{TO_EMAIL}>\n"
		msgstr += "Subject: Seat Available ("
		msgstr += time.month.to_s + "/" + time.day.to_s + " - "
		msgstr += time.hour.to_s + ":" + time.min.to_s + ")\n\n"
		msgstr += "Seats Available In:\n"

		for course in availableCourses
			msgstr += course[:subject] + " " + course[:course] + " " + course[:section]
			msgstr += " (" + course[:remaining] + " seats available)\n"
			msgstr += course[:link] + "\n\n"
		end

		smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start("GOOGLE", FROM_EMAIL, PASSWORD, :login) do
      smtp.send_message(msgstr, FROM_EMAIL, TO_EMAIL)
    end
		puts "EMAIL SENT"
	else
		puts "NO OPENINGS"
	end
end

while true
	main()
	sleep 300 	# How often you want to run the script (seconds)
end
