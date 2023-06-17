from flask import Flask, render_template, request
import csv
import subprocess

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def enrollment():
    if request.method == 'POST':
        agency_name = request.form['agency_name']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        email = request.form['email']
        phone = request.form['phone']
        username = request.form['username']
        password1 = request.form['password1']
        password2 = request.form['password2']

        # Check for missing required fields
        if not agency_name or not first_name or not last_name or not email or not username or not password1 or not password2:
            error_required_fields = "Please fill in all required fields."
            return render_template('enrollment.html', error_required_fields=error_required_fields)

        # Validate password format
        if not validate_password(password1):
            error_invalid_format = "Invalid password format!"
            return render_template('enrollment.html', error_invalid_format=error_invalid_format)

        # Check if passwords match
        if password1 != password2:
            error_password_mismatch = "Passwords do not match!"
            return render_template('enrollment.html', error_password_mismatch=error_password_mismatch)

        # Write to CSV file
        write_to_csv(agency_name, first_name, last_name, email, phone, username)

        # Execute command to create a new user
        command = ['sudo', 'java', '-jar', '/opt/tak/utils/UserManager.jar', 'usermod', '-p', password1, username]

        # Reset error messages and display success message
        error_invalid_format = ""
        error_password_mismatch = ""
        error_required_fields = ""
        success_message = "Account created successfully!"
        return render_template('enrollment.html', success_message=success_message,
                               error_invalid_format=error_invalid_format,
                               error_password_mismatch=error_password_mismatch,
                               error_required_fields=error_required_fields)

    return render_template('enrollment.html')


def validate_password(password):
    if len(password) < 15:
        return False
    if not any(char.islower() for char in password):
        return False
    if not any(char.isupper() for char in password):
        return False
    if not any(char.isdigit() for char in password):
        return False
    if not any(not char.isalnum() for char in password):
        return False
    return True


def write_to_csv(agency_name, first_name, last_name, email, phone, username):
    with open('enrollment_data.csv', 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([agency_name, first_name, last_name, email, phone, username])


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
