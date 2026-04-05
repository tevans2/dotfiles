#!/bin/bash
# Quick web search from the terminal using ddgr + w3m
# Usage: ? your search query

BROWSER=w3m ddgr "$*"
