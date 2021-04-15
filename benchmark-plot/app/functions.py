import os
import json
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime

in_folder = os.environ.get('INPUT_FOLDER')
out_folder = os.environ.get('OUTPUT_FOLDER')
json_ext = ".json"


def json_to_chart(rps):
    labels = []
    latencies_mean = []
    success = []
    throughput = []

    print(datetime.now().strftime(
        "%d/%m/%Y %H:%M:%S.%f") + " => Pesquisando arquivos JSON que contenham o termo '" + rps + "' no nome ...")

    filelist = os.listdir(in_folder)
    filelist.sort(reverse=True)

    for filename in filelist:
        if rps in filename and filename.endswith(json_ext):
            with open(in_folder + "/" + filename, 'r') as jsonfile:
                data = jsonfile.read()

            jsonobj = json.loads(data)

            labels.append(filename.split(".")[0])
            latencies_mean.append(round(jsonobj['latencies']['mean'] / 1000000000, 2))
            success.append(round(jsonobj['success'] * 100, 2))
            throughput.append(round(jsonobj['throughput'], 0))

    print(datetime.now().strftime("%d/%m/%Y %H:%M:%S.%f") + " => Gerando gráficos ...")
    generate_chart(labels, latencies_mean, "red", "Latency (ms)", "Latency", "Benchmark - Latency - " + rps, "latency", rps)
    generate_chart(labels, success, "green", "Success (%)", "Success", "Benchmark - Success - " + rps, "success", rps)
    generate_chart(labels, throughput, "blue", "Throughput (/s)", "Throughput", "Benchmark - Throughput - " + rps, "throughput", rps)
    print(datetime.now().strftime("%d/%m/%Y %H:%M:%S.%f") + " => ... Fim")


def generate_chart(labels, content, color, xlabel, label, title, filename, rps):
    y = np.arange(len(labels))
    width = 0.6
    fig, ax = plt.subplots()
    col = ax.barh(labels, content, width, label=label, color=color)
    ax.set_xlabel(xlabel)
    ax.set_yticks(y)
    ax.set_yticklabels(labels)
    ax.bar_label(col, padding=0.5, fontsize=5)
    fig.tight_layout()
    plt.title(title)
    plt.xticks(fontsize=6)
    plt.yticks(fontsize=6)
    plt.tight_layout()

    plt.savefig(out_folder + "/" + filename + "." + rps + ".png", dpi=200)