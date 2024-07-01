from move_id_app.classifiers.classifiers import OneClassClassifier
from sklearn.svm import OneClassSVM
from sklearn.preprocessing import StandardScaler

class OneClassSVMClassifier(OneClassClassifier):
    
    def __init__(self):
        super().__init__(0.7,OneClassSVM, {'nu' : 0.2, 'gamma' : 'auto', 'kernel' : 'sigmoid' })
        self.scaler = StandardScaler()
        

    def fit(self,X_train):
        
        self.scaler.fit(X_train)
        X_train_scalled = self.scaler.transform(X_train)
        self.model.fit(X_train_scalled)

    
    def predict(self,X):
        X_test_scalled = self.scaler.transform(X)
        y_pred = self.model.predict(X)
        for y in y_pred:
            if y == -1:
                return 1
        return 0
            

