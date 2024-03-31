#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
from typing import List
import os
import subprocess
import tkinter as tk
import requests
import dotenv

dotenv.load_dotenv()
url = os.environ["MODAL_URL"]

"""/search_command gname query
/add_command gname command 
/add_env gname repo content
/get_env gname repo
/make_commit gname repo diff_contents #returns llm response
/add_commit gname repo commit_message commit_hash branch #adds to mongo
/search_commit gname repo query 
"""

gname_var = "PH_GNAME"
def get_gname():
    gname = os.environ.get(gname_var)
    gname = gname if gname is not None else "default"
    return gname
def git_diff():
    exclude_paths = ["node_modules/", "venv/", "*.log", "*.swp", "*.bak", ".cache", ".env", ".config"] # useless files 
    git_diff_command = ["git", "diff"]
    for path in exclude_paths:
        git_diff_command.append(f":(exclude){path}")
    diff_output = subprocess.check_output(git_diff_command)
    diff_output = diff_output.decode('utf-8')
    return diff_output

root, text_box, edited_commit_message = None, None, None
def on_closing():
    global root, text_box, edited_commit_message
    text = text_box.get("1.0", tk.END)
    edited_commit_message = text
    root.destroy()
    
def cancel():
    global edited_commit_message, root
    edited_commit_message = None
    root.destroy()
    
def confirm(): 
    global edited_commit_message, root
    edited_commit_message = text_box.get("1.0", tk.END)
    root.destroy()

def create_text_box(initial_text): 
    global root, text_box
    # Create the main window
    root = tk.Tk()
    root.title("Editable Text Box")

    # Create a text box
    text_box = tk.Text(root)
    text_box.pack(fill=tk.BOTH, expand=True)
    text_box.insert(tk.END, initial_text)
    
    # add buttons
    cancel_button = tk.Button(root, text="Cancel", command=cancel)
    cancel_button.pack(side=tk.LEFT, padx=5, pady=5)
    confirm_button = tk.Button(root, text="Confirm", command=confirm)
    confirm_button.pack(side=tk.RIGHT, padx=5, pady=5)

    # Center the window on the screen
    window_width = 400
    window_height = 350
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width - window_width) // 2
    y = (screen_height - window_height) // 2
    root.geometry(f"{window_width}x{window_height}+{x}+{y}")

    # Bind the closing event
    root.protocol("WM_DELETE_WINDOW", on_closing)

    # Run the application
    root.mainloop()

def git_push(commit_message): 
    subprocess.check_output(["git", "commit", "-m", commit_message])
    subprocess.check_output(["git", "push"])

# returns the current branch name and the commit hash
def get_current_git_info():
    return subprocess.check_output(["git", "branch", "--show-current"]).decode('utf-8'), subprocess.check_output(["git", "rev-parse", "HEAD"]).decode('utf-8')

def perform_commit(repo):
    # send to post request to server to make a commit
    diff = git_diff()
    obj = { "gname": get_gname(), "repo": repo, "diff_contents": diff }
    res = requests.post(url + "/make_commit", json=obj)
    
    # # open in a text box that is editable 
    unedited_commit_message = json.loads(res.text)["commit_message"]
    create_text_box(unedited_commit_message)
    
    # do a wait until the user confirms or cancels
    
    if not edited_commit_message: print("cancelled commit"); return
    
    # if confirmed, perform a push 
    git_push(edited_commit_message)
    
    # add to mongo
    branch, commit_hash = get_current_git_info()
    obj = { "gname": get_gname(), "repo": repo, "commit_message": edited_commit_message, "commit_hash": commit_hash, "branch": branch }
    res = requests.post(url + "/add_commit", json=obj)
    print("commmit pushed")
    
    
    
    

def perform_search(query):
    print(query)

def perform_fetch(repo):
    obj = { "gname": get_gname(), "repo": repo}
    res = requests.post(url + "/get_env", json=obj)
    env_info = res.json()["env"]
    with open(".env", "w") as file:
        file.write(env_info)
    print(env_info)

def perform_ask(question):
    print(question)

def perform_env(repo):
    echo_env = ["cat", ".env"]
    env_contents = subprocess.check_output(echo_env)
    env_contents = env_contents.decode('utf-8')
    obj = { "gname": get_gname(), "repo": repo, "content": env_contents}
    res = requests.post(url + "/add_env", json=obj)
    return "done"

def perform_exit():
    print("Exit")

def perform_gname(gname):
    print(gname)

def main(commit, git_search, fetch_env, ask, env, exit, gname):
    if(commit is not None):
       perform_commit(commit)
    elif(git_search is not None):
       perform_search(git_search)
    elif(fetch_env is not None):
       perform_fetch(fetch_env)
    elif(ask is not None):
       perform_ask(ask)
    elif(env is not None):
       perform_env(env)
    elif(exit):
       perform_exit()
    elif(gname is not None):
       perform_gname(gname)





if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description = """This script sets up an environment that logs terminal commands allowing 
                         for future semantic search"""
    )

    parser.add_argument(
        "-c",
        "--commit",
        help = "get repo name for commiting"
    )

    parser.add_argument(
        "-s",
        "--git_search",
        help = "get a query to search for commits"
    )

    parser.add_argument(
        "-f",
        "--fetch_env",
        help = "fetches an environment from a repo"
    )

    parser.add_argument(
        "-a",
        "--ask",
        help = "ask a question based on current env"
    )

    parser.add_argument(
        "-e",
        "--env",
        help = "load a current environment into the server"
    )

    parser.add_argument(
        "--exit",
        default = False,
        action='store_true',
        help = "exit the current environment"
    )

    parser.add_argument(
        "--gname",
        help="create a hidden file given a group name"
    )

    args = parser.parse_args()

    main(args.commit, args.git_search, args.fetch_env, args.ask, args.env, args.exit, args.gname)







