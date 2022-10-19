import logging
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import balanced_accuracy_score



log = logging.getLogger()
def balanced_acc(data):
	def split(dataframe, border):
		return dataframe.loc[:border], dataframe.loc[border:]

	log.info("Processing input.")
	data_train, data_test = split(data, "2022-05-31")
	data_test = data_test.iloc[1:, :]
	X_train = data_train.iloc[:, [1, -3]].values
	y_train = data_train.iloc[:, -1].values
	X_test = data_test.iloc[:, [1, -3]].values
	y_test = data_test.iloc[:, -1].values


	log.info("Fitting model.")

	logisticRegr = LogisticRegression()
	logisticRegr.fit(X_train, y_train)

	log.info("Computing predictions.")
	y_pred = logisticRegr.predict(X_test)

	def return_balanced_acc(test,predicted):
		balanced_acc = balanced_accuracy_score(test, predicted)
		print("The balanced accuracy is {}.".format(balanced_acc))

	log.info("Processing output.")   
	balanced_acc = return_balanced_acc(y_test,y_pred)
	return balanced_acc



