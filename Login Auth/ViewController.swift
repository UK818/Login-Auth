//
//  ViewController.swift
//  Login Auth
//
//  Created by mac on 10/04/2022.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
	
	private let label: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = "Log in"
		label.font = .systemFont(ofSize: 24, weight: .semibold)
		return label
	}()
	
	private let emailField: UITextField = {
		let emailField = UITextField()
		emailField.placeholder = "Email Address"
		emailField.layer.borderWidth = 1
		emailField.layer.cornerRadius = 10
		emailField.autocapitalizationType = .none
		emailField.layer.borderColor = UIColor.black.cgColor
		emailField.leftViewMode = .always
		emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
		return emailField
	}()
		
	private let passwordField: UITextField = {
		let passwordField = UITextField()
		passwordField.placeholder = "Password"
		passwordField.layer.borderWidth = 1
		passwordField.layer.cornerRadius = 10
		passwordField.isSecureTextEntry = true
		passwordField.autocapitalizationType = .none
		passwordField.layer.borderColor = UIColor.black.cgColor
		passwordField.leftViewMode = .always
		passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
		return passwordField
	}()
	
	private let button: UIButton = {
		let button = UIButton()
		button.backgroundColor = .systemGreen
		button.setTitleColor(.white, for: .normal)
		button.setTitle("Continue", for: .normal)
		button.layer.cornerRadius = 20
		return button
	}()
	
	private let welcomeLabel: UILabel = {
		let welcomeLabel = UILabel()
		welcomeLabel.textAlignment = .center
		welcomeLabel.text = "Welcome"
		welcomeLabel.textColor = .blue
		welcomeLabel.font = .systemFont(ofSize: 30, weight: .semibold)
		return welcomeLabel
	}()
	
	private let signOutButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .systemGreen
		button.setTitleColor(.white, for: .normal)
		button.setTitle("Log out", for: .normal)
		button.layer.cornerRadius = 20
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(label)
		view.addSubview(emailField)
		view.addSubview(passwordField)
		view.addSubview(button)
		
		button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
		
		if FirebaseAuth.Auth.auth().currentUser != nil {
			label.isHidden = true
			button.isHidden = true
			emailField.isHidden = true
			passwordField.isHidden = true
			
			view.addSubview(welcomeLabel)
			view.addSubview(signOutButton)
			welcomeLabel.frame = CGRect(
				x: view.frame.origin.x + 20,
				y: 100,
				width: view.frame.size.width - 40,
				height: 40)
			signOutButton.frame = CGRect(
				x: 20,
				y: welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height + 100,
				width: view.frame.size.width - 40,
				height: 50
			)
			signOutButton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		label.frame = CGRect(
			x: 0,
			y: 100,
			width: view.frame.size.width,
			height: 80
		)
		
		emailField.frame = CGRect(
			x: 20,
			y: label.frame.origin.y + label.frame.size.height + 10,
			width: view.frame.size.width - 40,
			height: 50
		)
		
		passwordField.frame = CGRect(
			x: 20,
			y: emailField.frame.origin.y + emailField.frame.size.height + 10,
			width: view.frame.size.width - 40,
			height: 50
		)
		
		button.frame = CGRect(
			x: 20,
			y: passwordField.frame.origin.y + passwordField.frame.size.height + 10,
			width: view.frame.size.width - 40,
			height: 50
		)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if FirebaseAuth.Auth.auth().currentUser == nil {
			emailField.becomeFirstResponder()
		}
	}
	
	@objc func logOutTapped() {
		do {
			try FirebaseAuth.Auth.auth().signOut()
			
			label.isHidden = false
			button.isHidden = false
			emailField.isHidden = false
			passwordField.isHidden = false
			
			welcomeLabel.removeFromSuperview()
			signOutButton.removeFromSuperview()
		}
		catch {
			print("An error occurred")
		}
	}
 
	@objc func didTapButton() {
		print("Continue button tapped")
		guard let email = emailField.text, !email.isEmpty,
			  let password = passwordField.text, !password.isEmpty else {
				  print("Missing field data")
				  return
			  }
		
		// Get auth instance
		// attempt sign in
		// if failure, present alert to create account
		// if user continues, create account
		
		// check sign in on app launch
		// allow user to sign out with button
		
		FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
			guard let strongSelf = self else {
				return
			}
			guard error == nil else {
				// show account creation
				strongSelf.showCreateAccount(email: email, password: password)
				return
			}
			
			print("You have signed in")
			strongSelf.label.isHidden = true
			strongSelf.emailField.isHidden = true
			strongSelf.passwordField.isHidden = true
			strongSelf.button.isHidden = true
			
			strongSelf.emailField.resignFirstResponder()
			strongSelf.passwordField.resignFirstResponder()
		})
		
	}
	
	func showCreateAccount(email: String, password: String) {
		let message = "Would you like to create an account"
		let alert = UIAlertController(title: "Create Account",
									  message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Continue",
									  style: .default,
									  handler: { _ in
			FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
				guard let strongSelf = self else {
					return
				}
				guard error == nil else {
					// show account creation
					print("Account creation failed")
					return
				}
				
				print("You have signed in")
				strongSelf.label.isHidden = true
				strongSelf.emailField.isHidden = true
				strongSelf.passwordField.isHidden = true
				strongSelf.button.isHidden = true
			})
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel",
									  style: .cancel,
									  handler: { _ in
			
		}))
		
		present(alert, animated: true)
		
	}

}

