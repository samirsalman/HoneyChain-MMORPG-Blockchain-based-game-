using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ScenePersist : MonoBehaviour {

    int startingSceneIndex;

    private void Awake()
    {
        int numScenePersist = FindObjectsOfType<ScenePersist>().Length;
        if (numScenePersist > 1)
        {
            Destroy(gameObject);
            Debug.Log("destroying scene persistent!");
        }
      
        else
        {
            DontDestroyOnLoad(this.gameObject);
            Debug.Log("don t destroying scene persistent!");
        }
    }

    // Use this for initialization
    void Start () {
        startingSceneIndex = SceneManager.GetActiveScene().buildIndex;
	}
	
	// Update is called once per frame
	void Update () {
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        if (currentSceneIndex != startingSceneIndex)
        {
            Destroy(gameObject);
            Debug.Log("destroy not aligned");
        }
	}
}
