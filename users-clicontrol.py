# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description:  Create, delete or edit more accounts at once at an application using API

import time
import requests
import os
import json
import uuid

class Bulk:
    url = ""
    headers = {"Content-Type": "application/json"}
    tenant = 'default'
    admin_username = 'Admin'
    connected = False
    create_users_collected = False
    delete_users_collected = False
    S = '>> '
    
    def __init__(self):
        while True:
            option = input(f'Choose server:\n\n1 - Server1\n2 - Server2\n3 - Server3\n\n{self.S}')

            if option == "1":
                self.url = "server1.server.com"
                self.admin_password = 'Serv1SecP@ss'
                self.clear()
                break

            elif option == "2":
                self.url = "server2.server.com"
                self.admin_password = 'Serv2SecP@ss'
                self.clear()
                break

            elif option == "3":
                self.url = "server3.server.com"
                self.admin_password = 'Serv3SecP@ss'
                self.clear()
                break

            else:
                self.clear()

    def update_urls(self, url):
        self.login_url = f"http://{url}/server1/repo1/sub_folder/server_api/auth/Login"
        self.logout_url = f"http://{url}/server2/repo2/sub_folder/server_api/auth/Logout"
        self.user_url = f"http://{url}/server3/repo3/sub_folder/server_api/user"

    def connect(self):
        self.update_urls(self.url)
        self.session = requests.Session()
        login = self.session.post(url=self.login_url, data={"user": self.admin_username, "password": self.admin_password}, headers={"Accept": "application/json"})

        if login.status_code == 200 or login.status_code == 201:
            print(f'Connected to {self.url} ({login.status_code} OK)')
            self.connected = True

        else:
            print('Could not connect.')

    def collect_users(self, option='create'):
        username_template = str(input(f'\nEnter username template, letters only\n{self.S}'))
        username_start = int(input(f'\nEnter username START sequence number, digits only\n{self.S}'))
        username_end = int(input(f'\nEnter username END sequence number, digits only\n{self.S}'))

        if option == 'create':
            password = str(input(f'\nEnter bulk password (Leave empty to set to same as each username)\n{self.S}'))
            disp_name = str(input(f'\nEnter display name (Leave empty to set to same as each username)\n{self.S}'))

            while True:
                is_extension_same = input(f'\nShould extension numbers be the same as username sequence numbers? Y/N\n{self.S}').lower()
                
                if is_extension_same == 'y':
                    extension = username_start
                    break

                elif is_extension_same == 'n':
                    extension = int(input(f'\nEnter extension START sequence number (digits only)\n{self.S}'))
                    break
                
                else:
                    print('Invalid input.')

            self.create_users_collected = True
            return [username_template, username_start, username_end, password, disp_name, extension]

        elif option == 'delete':
            self.delete_users_collected = True
            return [username_template, username_start, username_end]

    def build_users(self, collected_users):
        if self.create_users_collected:
            self.username_template = collected_users[0].upper()
            self.username_start = collected_users[1]
            self.username_end = collected_users[2]
            self.password = collected_users[3]
            self.disp_name = collected_users[4]
            self.extension = collected_users[5]
            self.create_users_collected = False
        
        elif self.delete_users_collected:
            self.username_template = collected_users[0].upper()
            self.username_start = collected_users[1]
            self.username_end = collected_users[2]
            self.delete_users_collected = False

    def create_users(self):
        if self.username_end >= self.username_start:
            print('\n')

            while self.username_start <= self.username_end:
                full_username = f'{self.username_template}{self.username_start}'
                password = self.password if self.password != '' else full_username
                disp_name = self.disp_name if self.disp_name != '' else full_username

                user_params = {
                    "UUID": str(uuid.uuid1()),
                    "UserName": full_username,
                    "UserPassword": password,
                    "UserDescription": disp_name,
                    "DefaultExtension": self.extension,
                    "Path": f"path/all_users/{full_username}",
                    "DataType": "User",
                    "CurrFailedAttempts": 0,
                    "OsAuth": False,
                    "LockedOut": False,
                    "webrtc": True,
                    "Permissions": 1,
                    "FromDatabase": False,
                    "Revision": 1,
                }

                # Add user
                user_params = json.dumps(user_params)
                create_user = self.session.post(url=self.user_url, data=user_params, headers=self.headers)
                
                if create_user.status_code == 200 or create_user.status_code == 201:
                    print(f'> Creating user {full_username} with extension {self.extension}')

                else:
                    print(f'> User {full_username} with extension {self.extension} could not be created: Reason unknown')

                self.username_start += 1
                self.extension += 1
                
            print('> Done')

        else:
            print('\nError: START seq number was larger than END seq number')

    def delete_users(self):
        if self.username_end >= self.username_start:
            print('\n')

            while self.username_start <= self.username_end:
                full_username = f'{self.username_template}{self.username_start}'
                user_url = f'{self.user_url}/{full_username}'

                delete_user = self.session.delete(url=user_url)
                if delete_user.status_code == 200 or delete_user.status_code == 201:
                    print(f'> Deleting user {full_username}')

                elif delete_user.status_code == 404:
                    print(f'> User {full_username} could not be deleted: User not found')

                else:
                    print(f'> User {full_username} could not be deleted: Reason unknown')

                self.username_start += 1
            
            print('> Done')
        
        else:
            print('\nError: START seq number was larger than END seq number')

    def check_user_params(self, name, def_ext, lock_out, webrtc):
        name = name if name != '' else '???'
        def_ext = def_ext if def_ext != '' else '???'
        lock_out = lock_out if lock_out != '' else '???'
        webrtc = webrtc if webrtc != None else '???'

        return f"{name}\t\t{def_ext}\t\t{lock_out}\t\t\t{webrtc}"

    def list_users(self):
        user_dict = {}
        page = 1
        user_count = 0
        overall = 0

        while True:
            users = self.session.get(url=f'{self.user_url}?limit=25&page={page}', headers=self.headers)

            if users.status_code == 200 or users.status_code == 201:
                u = users.json()

                print(f'\nPAGE {page} |')
                print('Username\t\tExt\t\tLocked out\t\tWebRTC enabled')
                print('---\t\t\t---\t\t---\t\t\t---\t\t')
                
                for user in u['values']:
                    print(self.check_user_params(user['Name'], user['DefaultExtension'], user['LockedOut'], user['webrtc']))                    
                    overall += 1
            
                user_count += len(u['values'])
                
                if u['count'] > user_count:
                    page += 1

                else:
                    print(f'\n\nLISTED {overall} USERS IN ALPHABETICAL ORDER')
                    break

            else:
                print('Something went wrong, cannot list users.')
    # End session
    def disconnect(self):    
        logout = self.session.post(url=self.logout_url)
        if logout.status_code == 200 or logout.status_code == 201:
            print(f'\nDisconnected from {self.url} ({logout.status_code} OK)')

    def split_zero(self, str_number):
        number, zero = '', ''
        
        for i in str_number:
            if int(i) < 1:
                zero += i
            else:
                number += i
        
        return [zero, int(number)]

    def animate_text(self, text):
        output = ''
        for i in range(len(text)):
            output += text[i]
            print(output)
            time.sleep(0.01)
            if i != len(text)-1:
                self.clear()

    def clear(self):
        if os.name == 'nt':
            os.system('cls')
        else:
            os.system('clear')

# PROGRAM START...
b = Bulk()
S = b.S

b.connect()

if b.connected:
    while True:
        start = input(f'\n1 - Create user(s)\n2 - Delete user(s)\n3 - List existing users\n4 - Disconnect\n\n{S}')
        
        if start == "1":
            b.clear()
            print('CREATE USERS')
            collected_users = b.collect_users()
            b.build_users(collected_users)
            b.create_users()

        elif start == "2":
            b.clear()
            print('DELETE USERS')
            collected_users = b.collect_users('delete')
            b.build_users(collected_users)
            b.delete_users()

        elif start == "3":
            b.clear()
            b.list_users()

        elif start == "4":
            b.disconnect()
            break

        else:
            b.clear()
            print(f'Connected to {b.url}')

input('\nPress any key to exit...')