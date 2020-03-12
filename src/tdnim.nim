# docopt用のコマンドライン引数定義
const doc = """
Usage:
  tdnim <action> [[<content>],[<tag>]] [-t | --tag]

Options:
  <action>    ToDo Action
  <content>   ToDo Content
  <tag>       ToDo Task Tag
  -t --tag    ToDo Tag Option
"""

import system, os, options, random, times, strUtils
import docopt
import nimSHA2
import streams

const
  DATA_TASK_DIR = getHomeDir() & ".tdnim/tasks"
  DATA_TAG_DIR = getHomeDir() & ".tdnim/tags"

# 現在時刻のSHA256ハッシュを生成
proc getNowHash: string =
    let nowStr: string = format(now(), "yyyy/MM/dd HH:mm:ss")
    return $(computeSHA256(nowStr).hex())

# tdnimの初期化
proc init =
    if os.existsFile(DATA_TASK_DIR) and os.existsFile(DATA_TAG_DIR):
        echo "already initialized."
    else:
        # create data directory
        createDir(getHomeDir() & ".tdnim")
        writeFile(DATA_TASK_DIR, "")
        writeFile(DATA_TAG_DIR, "")

##########################################################################
## 追加

# タスクの追加
proc add_task(task: string, tag: string) =
    let taskLine: string = getNowHash() & " " & task & " " & tag
    #writeFile(DATA_TASK_DIR, taskLine)
    var f : File = open(DATA_TASK_DIR, FileMode.fmAppend)
    writeLine(f, taskLine)
    defer :
        close(f)
    echo "Task added: " & task

# ラベルの追加
proc add_tag(tag: string) =
    let tagLine: string = getNowHash() & " " & tag
    #writeFile(DATA_TAG_DIR, tagLine)
    var f: File = open(DATA_TAG_DIR, FileMode.fmAppend)
    writeLine(f, tagLine)
    defer:
        close(f)
    echo "Tag added: " & tag

##########################################################################
## リスト表示

# TASKリストを表示
proc list_task =
    var f : File = open(DATA_TASK_DIR , FileMode.fmRead)
    defer :
        close(f)
    echo f.readAll()

# Tagリストを表示
proc list_tag =
    var f : File = open(DATA_TAG_DIR , FileMode.fmRead)
    defer :
        close(f)
    echo f.readAll()

##########################################################################
## 削除

# TASK削除
proc del_task(task_hash: string) =
    # TODO hashに該当したラインを削除
    var f: File = open(DATA_TASK_DIR, fmRead)
    var task_lines = newStringStream(f.readAll())
    defer:
        close(f)
    writeFile(DATA_TASK_DIR, "")

    var f2: File = open(DATA_TASK_DIR, fmAppend)
    for task in task_lines.lines():
        if(not contains(task, task_hash)):
            writeLine(f2, task)
    defer:
        close(f2)
    echo "Task Deleted: " & task_hash

# TAG削除
proc del_tag(tag_hash: string) =
    # TODO hashに該当したラインを削除
    echo "Tag Deleted: "


# Idea
proc randomStr(size: int): string =
    for _ in .. size:
        add(result, char(rand(int('A') .. int('z'))))

proc main =
    let
        args = docopt(doc, version = "1.0.0")
        action: string = $args["<action>"]
        content: string = $args["<content>"]
        tag: string = $args["<tag>"]
        isTag: bool = if args["--tag"]: true else: false

    case action:
        of "init":
            # dataディレクトリを初期化
            init()
            echo "Initilize Completed."
        of "add":
            # contentがnilでなければ追加を実行
            if content == "nil":
                echo "content required"
            else:
                if isTag:
                    add_tag(content)
                else:
                    add_task(content, tag)
        of "list":
            if isTag:
                list_tag()
            else:
                list_task()
        of "delete":
            del_task(content)
            echo "delete"
        of "move":
            echo "move"
        else:
            echo "command does not exists : " & action

main()
