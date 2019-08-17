FROM arm32v7/python:3

WORKDIR /usr/src/app

# COPY requirements.txt ./
# RUN pip install --no-cache-dir -r requirements.txt
RUN python3 -m pip install tornado

COPY src/ .

CMD [ "python3", "./RFLinkGateway.py" ]