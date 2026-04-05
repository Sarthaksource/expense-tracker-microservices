from ..utils.messagesUtil import MessagesUtil
from .regexService import RegexService


class MessageService:
    def __init__(self):
        self.messageUtil = MessagesUtil()
        self.regexService = RegexService()

    def process_message(self, message):
        if self.messageUtil.isBankSms(message):
            return self.regexService.extract(message)
        else:
            return None
