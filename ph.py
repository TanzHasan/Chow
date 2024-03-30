#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
from typing import List

from lib.utils import perform_commit, perform_ask, perform_env, perform_exit, perform_fetch, perform_gname, perform_search


def main(commit, git_search, fetch_env, ask, env, exit, gname):
    print(commit)
    if(commit is not None):
       perform_commit(commit)
    elif(git-search is not None):
       perform_search(git_search)
    elif(fetch-env is not None):
       perform_fetch(fetch_env)
    elif(ask is not None):
       perform_ask(ask)
    elif(env is not None):
       perform_env(env)
    elif(exit is not None):
       perform_exit()
    elif(gname is not None):
       perform_gname(gname)





if __name__ == "_main_":
    print("kill me")
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
        "--git-search",
        help = "get a query to search for commits"
    )

    parse.add_argument(
        "-f",
        "--fetch-env",
        help = "fetches an environment from a repo"
    )

    parse.add_argument(
        "-a",
        "--ask",
        help = "ask a question based on current env"
    )

    parse.add_argument(
        "-e",
        "--env",
        help = "load a current environment into the server"
    )

    parse.add_argument(
        "--exit",
        action='store_true',
        help = "exit the current environment"
    )

    parse.add_argument(
        "--gname",
        help="create a hidden file given a group name"
    )

    args = parser.parse_args()
    print(args.commit)

    main(args.commit, args.git-search, args.fetch-env, args.ask, args.env, args.exit, args.gname)







